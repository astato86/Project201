# 201 Project

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
- Your dataset file: `stats.csv`.

## How to Export Your Matches into a CSV File
1. Visit [tracker.gg/valorant](https://tracker.gg/valorant) and search for your profile.  
2. Scroll down and load as many matches as you want (recommended: at least 100).  
3. Download the page by right-clicking on any blank space and saving it.  
4. Open the `.htm` file, search for your matches, copy and paste into a `.txt` file.  
   Example format in the `.txt` file:

K/D<br>
0.7<br>
DDΔ<br>
-34<br>
HS%<br>
17<br>
ADR<br>
94<br>
ACS<br>
142<br>
Skye<br>
Competitive • 3h ago<br>
Split<br>
Diamond 2<br>
11:13<br>
10th<br>
Performance Score<br>
228<br>
K / D / A<br>
9 / 17 / 5

5. Use Gemini (or any LLM tool) to transform the `.txt` file into CSV format.  
Example command:<br>

Agent: Chamber<br>
Competitive • 1yr ago<br>
Breeze<br>
Rank: Diamond 1<br>
Result: 13:5<br>
Position: 6th<br>
Performance Score: 648<br>
K / D / A: 12 / 10 / 2<br>
K/D: 1.2<br>
DDΔ: +3<br>
HS%: 25<br>
ADR: 114<br>
ACS: 169<br>
Convert into CSV with the following structure: partida,mvp,resultado_binario,resultado_texto,kills,deaths,assists,kda,agente. Ignore dates.

6. Save the final file as `stats.csv`. Place your stats.csv file in the same folder as the script.

## Usage
    
### Packages
```bash
pip install pandas numpy scikit-learn xgboost 
```

    Run the script:

### Linux / Mac

```bash
python RankedPredict.py
```
### Windows

```bash
python RankedPredict.py
```
## Output 
Final predictions for match 201 (Top 3 agents per map):

Map: Ascent
  - Jett | Win Probability 0.72 | Expected KDA 2.10
  - Reyna | Win Probability 0.65 | Expected KDA 1.95
  - Killjoy | Win Probability 0.60 | Expected KDA 1.80


