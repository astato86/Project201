import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder, StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# 1) Cargar dataset
df = pd.read_csv("stats.csv")

# 2) Invertir orden (tu CSV está en orden inverso: fila 2 = última partida)
df = df.iloc[::-1].reset_index(drop=True)

# 3) Codificar variables categóricas
le_mapa = LabelEncoder()
le_agente = LabelEncoder()
df["mapa_enc"] = le_mapa.fit_transform(df["mapa"])
df["agente_enc"] = le_agente.fit_transform(df["agente"])

# 4) Features y target
features = ["mapa_enc", "agente_enc", "kills", "deaths", "assists"]
target = "resultado_binario"

X = df[features].values
y = df[target].values

# 5) Escalar
scaler = StandardScaler()
X = scaler.fit_transform(X)

# 6) Crear secuencias para LSTM (ventana de 10 partidas)
def create_sequences(X, y, window=10):
    Xs, ys = [], []
    for i in range(len(X) - window):
        Xs.append(X[i:i+window])
        ys.append(y[i+window])
    return np.array(Xs), np.array(ys)

X_seq, y_seq = create_sequences(X, y, window=10)

# 7) Definir modelo LSTM
model = Sequential()
model.add(LSTM(64, input_shape=(X_seq.shape[1], X_seq.shape[2])))
model.add(Dropout(0.3))
model.add(Dense(32, activation="relu"))
model.add(Dense(1, activation="sigmoid"))

model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])

# 8) Entrenar
model.fit(X_seq, y_seq, epochs=20, batch_size=16, verbose=1)

# 9) Predicción de la siguiente partida (201)
# Usamos las últimas 10 partidas como input
last_seq = X[-10:]
last_seq = np.expand_dims(last_seq, axis=0)

# Probabilidad base de victoria
proba_base = model.predict(last_seq)[0][0]

# 10) Evaluar agentes posibles en el próximo mapa
mapa_actual = "Ascent"  # cámbialo al mapa que te toque
agentes_posibles = df[df["mapa"] == mapa_actual]["agente"].unique()

resultados = []
for agente in agentes_posibles:
    agente_enc = le_agente.transform([agente])[0]
    mapa_enc = le_mapa.transform([mapa_actual])[0]

    # Stats promedio recientes en ese mapa (últimas 10 partidas)
    stats_mapa = df[df["mapa"] == mapa_actual].tail(10)[["kills","deaths","assists"]].mean()

    features_pred = np.array([[mapa_enc, agente_enc,
                               stats_mapa["kills"], stats_mapa["deaths"], stats_mapa["assists"]]])
    features_pred = scaler.transform(features_pred)

    # Construir secuencia con las últimas 9 partidas + esta predicción hipotética
    seq_pred = np.vstack([X[-9:], features_pred])
    seq_pred = np.expand_dims(seq_pred, axis=0)

    proba_victoria = model.predict(seq_pred)[0][0]
    resultados.append((agente, proba_victoria))

# 11) Top 3 agentes
top3 = sorted(resultados, key=lambda x: x[1], reverse=True)[:3]

print("\nTop 3 agentes para la siguiente partida en", mapa_actual)
for agente, proba in top3:
    print(f" - {agente}: Prob. victoria {proba:.2f}")
