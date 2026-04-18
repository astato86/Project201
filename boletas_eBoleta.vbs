' ======================================================================
' AUTOMATIZACIÓN E-BOLETA SII - VBScript
' ======================================================================
' Lee base de datos Access, detecta ventas en efectivo,
' emite boleta en e-Boleta e imprime automáticamente.
'
' Compatible con Windows 7 sin Service Pack 1
' No requiere instalación adicional
' ======================================================================

Option Explicit

' === CONFIGURACIÓN ===
Dim RUTA_TRABAJO : RUTA_TRABAJO = "C:\Program Files\Tienda"
Dim RUTA_DB : RUTA_DB = RUTA_TRABAJO & "\BASE.mdb"
Dim PASSWORD_DB : PASSWORD_DB = "xinergia"
Dim URL_EBOLETA : URL_EBOLETA = "https://eboleta.sii.cl/emitir/"
Dim INTERVALO_MS : INTERVALO_MS = 1000
Dim ARCHIVO_ULTIMO : ARCHIVO_ULTIMO = RUTA_TRABAJO & "\ultimo_procesado.txt"
Dim LOG_FILE : LOG_FILE = RUTA_TRABAJO & "\logs\boletas_log.txt"

Dim ultimoProcesado
Dim oFSO : Set oFSO = CreateObject("Scripting.FileSystemObject")

' ======================================================================
' FUNCIONES DE LOG
' ======================================================================

Sub LogMsg(sMsg)
    Dim sFecha, sLinea, hFile
    sFecha = Year(Now) & "-" & Right("0" & Month(Now), 2) & "-" & Right("0" & Day(Now), 2) & " " & Right("0" & Hour(Now), 2) & ":" & Right("0" & Minute(Now), 2) & ":" & Right("0" & Second(Now), 2)
    sLinea = sFecha & " [INFO] " & sMsg & vbCrLf
    
    If Not oFSO.FolderExists(RUTA_TRABAJO & "\logs") Then
        oFSO.CreateFolder(RUTA_TRABAJO & "\logs")
    End If
    
    On Error Resume Next
    Set hFile = oFSO.OpenTextFile(LOG_FILE, 8, True) ' 8 = ForAppending
    If Err.Number = 0 Then
        hFile.Write sLinea
        hFile.Close
    End If
    On Error GoTo 0
    
    WScript.Echo sLinea
End Sub

Sub LogError(sMsg)
    Dim sFecha, sLinea, hFile
    sFecha = Year(Now) & "-" & Right("0" & Month(Now), 2) & "-" & Right("0" & Day(Now), 2) & " " & Right("0" & Hour(Now), 2) & ":" & Right("0" & Minute(Now), 2) & ":" & Right("0" & Second(Now), 2)
    sLinea = sFecha & " [ERROR] " & sMsg & vbCrLf
    
    If Not oFSO.FolderExists(RUTA_TRABAJO & "\logs") Then
        oFSO.CreateFolder(RUTA_TRABAJO & "\logs")
    End If
    
    On Error Resume Next
    Set hFile = oFSO.OpenTextFile(LOG_FILE, 8, True)
    If Err.Number = 0 Then
        hFile.Write sLinea
        hFile.Close
    End If
    On Error GoTo 0
    
    WScript.Echo sLinea
End Sub

' ======================================================================
' FUNCIONES DE BASE DE DATOS
' ======================================================================

Function ConectarBD()
    Dim conn, sConnString
    
    On Error Resume Next
    Set conn = CreateObject("ADODB.Connection")
    
    sConnString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & RUTA_DB & ";Jet OLEDB:Database Password=" & PASSWORD_DB & ";"
    conn.Open sConnString
    
    If Err.Number <> 0 Then
        LogError "Error conectando a BD: " & Err.Description
        Set conn = Nothing
        ConectarBD = False
        Exit Function
    End If
    
    On Error GoTo 0
    Set ConectarBD = conn
    LogMsg "Conexion a BASE.mdb establecida (Jet OLEDB 4.0)"
End Function

Function ObtenerUltimaVentaEfectivo(conn)
    Dim rs, sQuery, aResult(5)
    
    On Error Resume Next
    Set rs = CreateObject("ADODB.Recordset")
    
    ' Query: TOP 1 + ORDER BY Fecha DESC para la ultima en efectivo
    sQuery = "SELECT TOP 1 Numero, Fecha, Total, Monto_Efectivo, Vuelto, Cajero " & _
             "FROM Ordenes_Encabezado WHERE Monto_Efectivo > 0 ORDER BY Fecha DESC"
    
    rs.Open sQuery, conn, 1, 1 ' adOpenForwardOnly = 1, adLockReadOnly = 1
    
    If Err.Number <> 0 Then
        LogError "Error en query: " & Err.Description
        Set rs = Nothing
        Set ObtenerUltimaVentaEfectivo = Nothing
        Exit Function
    End If
    
    If rs.EOF Then
        rs.Close
        Set rs = Nothing
        Set ObtenerUltimaVentaEfectivo = Nothing
        Exit Function
    End If
    
    aResult(0) = CInt(rs("Numero").Value)
    aResult(1) = rs("Fecha").Value
    aResult(2) = CLng(rs("Total").Value)
    aResult(3) = CLng(rs("Monto_Efectivo").Value)
    aResult(4) = CLng(rs("Vuelto").Value)
    aResult(5) = rs("Cajero").Value
    
    rs.Close
    Set rs = Nothing
    
    Set ObtenerUltimaVentaEfectivo = aResult
    
    On Error GoTo 0
End Function

Function LeerUltimoProcesado()
    Dim sContenido, hFile
    
    On Error Resume Next
    If oFSO.FileExists(ARCHIVO_ULTIMO) Then
        Set hFile = oFSO.OpenTextFile(ARCHIVO_ULTIMO, 1) ' ForReading = 1
        If Err.Number = 0 Then
            sContenido = Trim(hFile.ReadAll)
            hFile.Close
            If sContenido <> "" Then
                LeerUltimoProcesado = CLng(sContenido)
                Exit Function
            End If
        End If
        hFile.Close
    End If
    On Error GoTo 0
    LeerUltimoProcesado = 0
End Function

Sub GuardarUltimoProcesado(iNumero)
    Dim hFile
    
    On Error Resume Next
    Set hFile = oFSO.OpenTextFile(ARCHIVO_ULTIMO, 2, True) ' ForWriting = 2, Create = True
    If Err.Number = 0 Then
        hFile.Write CStr(iNumero)
        hFile.Close
    End If
    On Error GoTo 0
End Sub

' ======================================================================
' FUNCIONES DE AUTOMATIZACIÓN CHROME VIA WSH
' ======================================================================

Dim oWshShell : Set oWshShell = CreateObject("WScript.Shell")
Dim oWshExec

Sub NavegarAChrome(sURL)
    Dim sChromePath, sCmd
    
    ' Detectar ruta de Chrome
    If oFSO.FileExists("C:\Program Files\Google\Chrome\Application\chrome.exe") Then
        sChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    ElseIf oFSO.FileExists("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") Then
        sChromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    Else
        sChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    End If
    
    ' Abrir Chrome con URL
    sCmd = """" & sChromePath & """ --new-window """ & sURL & """"
    
    LogMsg "Abriendo Chrome: " & sURL
    Set oWshExec = oWshShell.Exec(sCmd)
    
    WScript.Sleep 4000
End Sub

Sub EnviarTecla(sTecla)
    oWshShell.SendKeys sTecla
    WScript.Sleep 100
End Sub

Sub ClickBoton(sTexto)
    ' Los botones en e-Boleta tienen texto visible
    ' Usamos Tab para navegar y Enter para confirmar
    ' Esto simula navegación por teclado
    Select Case sTexto
        Case "7", "8", "9", "4", "5", "6", "1", "2", "3", "0"
            oWshShell.SendKeys sTexto
        Case "C"
            ' Limpiar - envir enter al boton C
            oWshShell.SendKeys "{ENTER}"
        Case "Emitir"
            ' Emitir esta en el keypad, 2 tabs desde ultimo numero
            oWshShell.SendKeys "{TAB}{TAB}{ENTER}"
        Case "Confirmar"
            ' Confirmar en modal
            oWshShell.SendKeys "{ENTER}"
    End Select
    WScript.Sleep 150
End Sub

Sub LimpiarDisplay()
    ' Click en boton C (rojo, primer boton)
    oWshShell.SendKeys "{TAB}"
    WScript.Sleep 100
    oWshShell.SendKeys "{ENTER}"
    WScript.Sleep 300
End Sub

Sub IngresarMonto(iMonto)
    Dim sMonto, i, sDigito
    
    sMonto = CStr(iMonto)
    LogMsg "Ingresando monto: $" & sMonto
    
    LimpiarDisplay
    
    For i = 1 To Len(sMonto)
        sDigito = Mid(sMonto, i, 1)
        oWshShell.SendKeys sDigito
        WScript.Sleep 150
    Next
End Sub

Sub EmitirBoleta()
    ' Click en Emitir (del keypad)
    ' Son 2 tabs + enter desde el ultimo digito
    LogMsg "Click en Emitir (pagsina 1)..."
    oWshShell.SendKeys "{TAB}{TAB}{ENTER}"
    WScript.Sleep 2000
    
    ' Modal abre con Efectivo seleccionado
    ' Confirmar: solo enter
    LogMsg "Confirmando en modal..."
    oWshShell.SendKeys "{ENTER}"
    
    ' Esperar respuesta SII
    WScript.Sleep 8000
End Sub

Sub ImprimirBoleta()
    ' Enviar Ctrl+P para imprimir
    LogMsg "Enviando a imprimir..."
    
    oWshShell.SendKeys "^{p}"
    WScript.Sleep 2000
    
    ' Enter para imprimir (usa predeterminada = CAJA)
    oWshShell.SendKeys "{ENTER}"
    
    WScript.Sleep 3000
End Sub

Sub CerrarChrome()
    ' Cerrar Chrome con Alt+F4
    oWshShell.SendKeys "%{F4}"
    WScript.Sleep 1000
End Sub

Function EsChromeActivo()
    Dim bResultado
    
    On Error Resume Next
    ' Intentar enviar una tecla simple para ver si Chrome responde
    oWshShell.AppActivate "Chrome"
    WScript.Sleep 200
    bResultado = (Err.Number = 0)
    On Error GoTo 0
    
    EsChromeActivo = bResultado
End Function

' ======================================================================
' PROCESAR VENTA
' ======================================================================

Sub ProcesarVenta(iNumero, iMonto)
    LogMsg "========================================"
    LogMsg "PROCESANDO VENTA #" & iNumero & " - Monto: $" & iMonto
    LogMsg "========================================"
    
    ' 1. Abrir Chrome con e-Boleta
    NavegarAChrome URL_EBOLETA
    WScript.Sleep 3000
    
    ' 2. Navegar al campo de monto (usando Tab hasta llegar al keypad)
    ' Nos posicionamos al inicio del keypad con Tab
    Dim j
    For j = 1 To 5
        oWshShell.SendKeys "{TAB}"
        WScript.Sleep 100
    Next
    
    ' 3. Ingresar el monto
    IngresarMonto iMonto
    WScript.Sleep 500
    
    ' 4. Emitir
    EmitirBoleta
    
    ' 5. Imprimir
    ImprimirBoleta
    
    ' 6. Cerrar Chrome
    CerrarChrome
    WScript.Sleep 1000
    
    LogMsg "Venta #" & iNumero & " procesada"
End Sub

' ======================================================================
' PROGRAMA PRINCIPAL
' ======================================================================

Sub Main()
    Dim conn, aVenta, iNumero, iMonto, sFecha, sCajero
    Dim iConteo, bPrimeraVez
    
    LogMsg "=========================================="
    LogMsg "INICIANDO AUTOMATIZADOR E-BOLETA"
    LogMsg "=========================================="
    LogMsg "Ruta BD: " & RUTA_DB
    LogMsg "Intervalo: " & INTERVALO_MS & "ms"
    LogMsg "=========================================="
    
    ' Crear directorio de logs
    If Not oFSO.FolderExists(RUTA_TRABAJO & "\logs") Then
        oFSO.CreateFolder(RUTA_TRABAJO & "\logs")
    End If
    
    ' Leer ultimo procesado
    ultimoProcesado = LeerUltimoProcesado()
    LogMsg "Ultimo procesado: #" & ultimoProcesado
    bPrimeraVez = (ultimoProcesado = 0)
    
    ' Conectar a base de datos
    Set conn = ConectarBD()
    If Not IsObject(conn) Then
        LogError "No se pudo conectar a la base de datos. Saliendo."
        WScript.Quit 1
    End If
    
    iConteo = 0
    
    LogMsg "Iniciando ciclo de polling cada " & INTERVALO_MS & "ms..."
    LogMsg "Presiona Ctrl+C o cierra esta ventana para detener"
    
    WScript.Echo ""
    WScript.Echo "AUTOMATIZADOR E-BOLETA ACTIVO"
    WScript.Echo "Presiona Ctrl+C para detener"
    WScript.Echo ""
    
    Do While True
        ' Consultar ultima venta en efectivo
        aVenta = ObtenerUltimaVentaEfectivo(conn)
        
        If IsArray(aVenta) Then
            iNumero = aVenta(0)
            iMonto = aVenta(3) ' Monto_Efectivo
            
            ' Solo procesar si es diferente al ultimo
            If iNumero <> ultimoProcesado And iMonto > 0 Then
                LogMsg "NUEVA VENTA: #" & iNumero & " - $" & iMonto & " - Cajero: " & aVenta(5)
                
                ' Procesar esta venta
                On Error Resume Next
                Call ProcesarVenta(iNumero, iMonto)
                
                If Err.Number = 0 Then
                    ultimoProcesado = iNumero
                    GuardarUltimoProcesado iNumero
                    iConteo = iConteo + 1
                    LogMsg "TOTAL PROCESADOS: " & iConteo
                Else
                    LogError "Error al procesar: " & Err.Description
                End If
                On Error GoTo 0
                
                ' Cerrar Chrome entre ventas
                WScript.Sleep 1000
            End If
        End If
        
        ' Dormir hasta siguiente ciclo
        WScript.Sleep INTERVALO_MS
    Loop
    
    ' Cleanup (nunca llega aqui)
    conn.Close
    Set conn = Nothing
End Sub

' ======================================================================
' EJECUTAR
' ======================================================================

Main()
