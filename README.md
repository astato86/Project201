# Project 201

## Overview
This project predicts the probability of winning the next Valorant match and recommends the **top 3 agents per map** based on:
- **Temporal patterns** → learns win/loss streaks and recent performance trends.
- **Tabular features** → evaluates map, agent, kills, deaths, assists, and predicts both win probability and expected KDA.
- **Hybrid combination** → averages both models’ probabilities to provide a more realistic recommendation.

## Workflow

### Requirements
- Python 3.9+ (recommended).
- Basic knowledge of using the terminal/command prompt.
- Your dataset file
- 
## Installing on Windows
1. Install python from [the microsoft store](https://apps.microsoft.com/detail/9PNRBTZXMB4Z?hl=neutral&gl=CL&ocid=pdpshare)
2. Open CMD and put:
```bash
pip install pandas numpy scikit-learn xgboost torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```
3. After finishing put the three files in a folder and go to your project folder location:
```bash
cd %folder%
```
## Installing on Linux/Mac
1. Install python from the terminal or from the [macos page](https://www.python.org/downloads/macos/)
2. Open terminal and put:
```bash
pip install pandas numpy scikit-learn xgboost torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```
Note: if this not work, go into a virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate
```
3. After finishing put the three files in a folder and go to your project folder location:
```bash
cd %folder%
```
##  To export your matches to a CSV file
1. Visit [tracker.gg/valorant](https://tracker.gg/valorant) and search for your profile.  
2. Scroll down and load as many matches as you want (recommended: at least 100).  
3. Download the page by right-clicking on any blank space and saving it.  
4. Open the `.htm` file, copy all and put in a .txt file, with your riot ID as the name of the .txt file.
5. Put the ID.txt file into the same folder as the entire project
6. Execute the launch.py  with
```bash
python launch.py
```
##### (Linux/Mac)
Note: if this not work, go to the previous virtual environment: 
```bash
python -m venv .venv
source .venv/bin/activate
```
7. select the option 2, put the same ID as the former ID.txt
8. Here you go, you have the .csv file to your folder with the same ID name, result: ID.csv

## Using on Linux/Mac:
1. Open terminal, go to your folder location
2. Launch the launch.py:
```bash
python launch.py
```
Note: if this not work, go to the previous virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate
```
3. Choose option 1 and put the same ID name of the former .csv file (your riot ID)
4. Choose the map putting only the name!

## Output 
Final predictions for the next match (all agents played per map):

Map: Ascent
  - Jett | Win Probability 0.72 | Expected KDA 2.10
  - Reyna | Win Probability 0.65 | Expected KDA 1.95
  - Killjoy | Win Probability 0.60 | Expected KDA 1.80
## Considerations
1. The model will be predicting matches according to the loaded matches from the .csv file, is it recommended to update the .csv file with every match you play for better results, for now you must to do manually overwritting the .csv file yourself, you must write a new line in the .csv file with the format you'll be seeing.
2. The model IS NOT 100% perfect, because is a alfa version, speaking of my own research i guess a 65%-80% correct predictons.

### Knowed future proyections
1. UI
2. Learning from the actual match
3. Updating the file automatically
## Shotouts
Special thanks to Revit and Magiñho for being test subjects.
