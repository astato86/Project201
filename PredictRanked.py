import pandas as pd
import numpy as np
from sklearn.model_selection import StratifiedKFold
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from xgboost import XGBClassifier, XGBRegressor
from sklearn.metrics import accuracy_score, roc_auc_score

# 1) Cargar dataset
df = pd.read_csv("stats.csv")

# 2) Features y targets
X = df[["mapa", "agente", "kills", "deaths", "assists"]]
y_victoria = df["resultado_binario"]
y_kda = df["kda"]

# 3) Preprocesamiento
numeric_features = ["kills", "deaths", "assists"]
categorical_features = ["mapa", "agente"]

preprocess = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), numeric_features),
        ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features)
    ]
)

# 4) Modelos
clf = Pipeline(steps=[("preprocess", preprocess),
                      ("model", XGBClassifier(
                          n_estimators=200,
                          max_depth=3,
                          learning_rate=0.1,
                          subsample=0.8,
                          colsample_bytree=0.8,
                          reg_lambda=10,
                          random_state=42,
                          eval_metric="logloss"
                      ))])

reg = Pipeline(steps=[("preprocess", preprocess),
                      ("model", XGBRegressor(
                          n_estimators=200,
                          max_depth=3,
                          learning_rate=0.1,
                          subsample=0.8,
                          colsample_bytree=0.8,
                          reg_lambda=10,
                          random_state=42
                      ))])

# 5) Entrenar con todo el dataset
clf.fit(X, y_victoria)
reg.fit(X, y_kda)

# 6) Calcular mejor agente por mapa (winrate histórico)
win_rates = df.groupby(["mapa", "agente"])["resultado_binario"].mean().reset_index()
best_agents = win_rates.loc[win_rates.groupby("mapa")["resultado_binario"].idxmax()]

print("\nMejores agentes por mapa según tus datos:")
print(best_agents)

# 7) Lista de mapas de Valorant
mapas_valorant = [
    "Abyss", "Ascent", "Bind", "Breeze", "Corrode",
    "Fracture", "Haven", "Icebox", "Lotus", "Pearl",
    "Split", "Sunset"
]

# 8) Predicción de la partida 201 para cada mapa usando estadísticas más próximas
print("\nPredicciones de la partida 201 por mapa (mejor agente + promedio últimas 5 partidas en ese mapa):")
for mapa in mapas_valorant:
    if mapa in best_agents["mapa"].values:
        mejor_agente = best_agents[best_agents["mapa"] == mapa]["agente"].values[0]

        # Últimas 5 partidas en ese mapa
        partidas_mapa = df[df["mapa"] == mapa].tail(5)
        if len(partidas_mapa) == 0:
            print(f"- {mapa}: No tienes datos suficientes en tu historial.")
            continue

        stats_mapa = partidas_mapa[["kills", "deaths", "assists"]].mean()

        partida_201 = pd.DataFrame([{
            "mapa": mapa,
            "agente": mejor_agente,
            "kills": stats_mapa["kills"],
            "deaths": stats_mapa["deaths"],
            "assists": stats_mapa["assists"]
        }])

        proba_victoria_201 = clf.predict_proba(partida_201)[0,1]
        kda_201 = reg.predict(partida_201)[0]

        print(f"- {mapa}: {mejor_agente} | Prob. victoria {proba_victoria_201:.2f} | KDA esperado {kda_201:.2f}")
    else:
        print(f"- {mapa}: No tienes datos suficientes en tu historial.")
