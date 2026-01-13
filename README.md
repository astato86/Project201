# PredictMyOwnRanked

## Overview
This project predicts the probability of winning the next Valorant match and recommends the **top 3 agents per map** based on:
- **Temporal patterns (LSTM in PyTorch)** → learns win/loss streaks and recent performance trends.
- **Tabular features (XGBoost in scikit-learn)** → evaluates map, agent, kills, deaths, assists, and predicts both win probability and expected KDA.
- **Hybrid combination** → averages both models’ probabilities to provide a more realistic recommendation.

## Workflow
1. **Data Preparation**
   - Load `stats.csv` (your match history).
   - Reverse order (CSV is stored with most recent matches at the top).
   - Encode categorical features (`map`, `agent`).
   - Scale numeric features (`kills`, `deaths`, `assists`).

2. **Models**
   - **LSTM (PyTorch)**: Trained on sequences of 10 matches to capture temporal win/loss patterns.
   - **XGBoost (scikit-learn)**:
     - Classifier → predicts win probability.
     - Regressor → predicts expected KDA.

3. **Prediction**
   - For each Valorant map:
     - Take the last 10 matches played on that map.
     - Compute average kills, deaths, assists.
     - Evaluate all agents you have played on that map.
     - Combine LSTM and XGBoost predictions.
     - Output the **top 3 agents** with highest win probability and expected KDA.

## Requirements
- Python 3.9+ (recommended).
- Basic knowledge of using the terminal/command prompt.
- Your dataset file: stats.csv.

# ¿How to export your matches in a CSV file?:
-1  Visit https://tracker.gg/valorant, search for your profile. 
-2 In the bottom part of the page, load as many matches as you want. (i recommend 100 at least)
-3 Download the page with right click on any blank space on the page.
-4 Once you have the page, go to the .htm file, search for your matches, copy and paste into a .txt file.
The format would be (in the .txt file):

K/D
0.7
DDΔ
-34
HS%
17
ADR
94
ACS
142
Skye
Competitive • 3h ago
Split
Diamond 2
11:13
10th
Performance Score
228
K / D / A
9 / 17 / 5

-5 since you have that, go to Gemini (i use gemini for personal prefference), upload the .txt file, put this command:
where the variables are:
agente: Chamber
Competitive • 1yr ago
Breeze
Rank: Diamond 1
Result: 13:5
Position: 6th
Performance Score:
648
K / D / A:
12 / 10 / 2
K/D:
1.2
DDΔ:
+3
HS%:
25
ADR:
114
ACS:
169
read data, put all matches into a csv format file following this structure:
partida,mvp,resultado_binario,resultado_texto,kills,deaths,assists,kda,agente 
ignore dates

-6 since gemini give you the data, copy to a new .txt file, and change the name and type to stats.csv

# Install dependencies:
```bash
pip install pandas numpy scikit-learn xgboost torch
```


## Output
Map: Ascent
  - Jett | Win Probability 0.72 | Expected KDA 2.10
  - Reyna | Win Probability 0.65 | Expected KDA 1.95
  - Killjoy | Win Probability 0.60 | Expected KDA 1.80



