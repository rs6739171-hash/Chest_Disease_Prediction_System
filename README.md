# Chest Disease Prediction System

An end-to-end Deep Learning and MLOps project for detecting and classifying chest abnormalities (Adenocarcinoma vs. Normal) from Chest CT-scan images using VGG16 transfer learning, DVC, and MLflow with DagsHub tracking.

---

## 📌 Project Overview

This system automates the diagnosis of chest diseases from CT scan slices using computer vision. Built following modular production-ready software engineering standards, each stage—from data ingestion to model evaluation—is decoupled, reproducible, and tracked.

- **Model Architecture**: VGG16 (pretrained on ImageNet) + Custom Flatten and Dense layers
- **Target Classes**: `Adenocarcinoma`, `Normal`
- **Experiment Tracking**: Remote MLflow server hosted on DagsHub
- **Pipeline Orchestration**: Modular stages configured via YAML

---

## ⚙️ Tech Stack & Tools

- **Core Deep Learning**: TensorFlow 2.12, Keras
- **Experiment Tracking**: MLflow, DagsHub
- **Data & Model Versioning**: DVC (Data Version Control)
- **Environment & Packaging**: `uv` package manager, Python 3.10
- **Configuration & Utilities**: PyYAML, python-box, ensure-annotations

---

## 📂 Project Structure

```text
Chest_Disease_Prediction_System/
├── .github/workflows/          # CI/CD workflows
├── config/
│   └── config.yaml             # File paths and artifact destinations
├── params.yaml                 # Hyperparameters (epochs, batch_size, learning_rate)
├── research/                   # Jupyter notebooks for prototyping
│   ├── 01_data_ingestion.ipynb
│   └── trials.ipynb
├── src/
│   └── cnnClassifier/
│       ├── __init__.py         # Custom logging configuration
│       ├── components/         # Core business logic for each stage
│       │   ├── data_ingestion.py
│       │   ├── prepare_base_model.py
│       │   └── training.py
│       │   └── evaluation.py
│       ├── config/
│       │   └── configuration.py# ConfigurationManager mapping YAML to entities
│       ├── constants/
│       │   └── __init__.py     # Static paths (config.yaml, params.yaml)
│       ├── entity/
│       │   └── config_entity.py# Dataclass entities enforcing types
│       ├── pipeline/           # Sequential pipeline stage wrappers
│       │   ├── stage_01_data_ingestion.py
│       │   ├── stage_02_prepare_basemodel.py
│       │   ├── stage_03_training.py
│       │   └── stage_04_model_evaluation.py
│       └── utils/
│           └── common.py       # Helper functions (read_yaml, save_json, etc.)
├── main.py                     # Pipeline execution entry point
├── requirements.txt            # Python package dependencies
├── setup.py                    # Local package installer
└── README.md
```

---

## 🚀 Workflow Stages

1. **Stage 01: Data Ingestion**
   - Automatically downloads chest CT scan data (`data.zip`) from Google Drive via `gdown`.
   - Extracts the images to `artifacts/data_ingestion/Chest-CT-Scan-data`.

2. **Stage 02: Prepare Base Model**
   - Instantiates a pretrained `VGG16` base model without top classification layers.
   - Adds custom `Flatten` and `Dense` layers with Softmax activation for 2 classes.
   - Saves both `base_model.h5` and `base_model_updated.h5`.

3. **Stage 03: Model Training**
   - Loads `base_model_updated.h5`.
   - Applies data augmentation (rotations, flips, zoom, shear) on training data with an 80/20 train-validation split.
   - Trains the model and saves the trained weights to `artifacts/training/model.h5`.

4. **Stage 04: Model Evaluation & MLflow Tracking**
   - Evaluates the model on validation data, computing `loss` and `accuracy`.
   - Saves scores locally to `scores.json`.
   - Automatically logs hyperparameters, metrics, and registers the model to the remote DagsHub MLflow tracking server.

---

## 🛠️ Installation & Setup

### 1. Clone the Repository
```powershell
git clone https://github.com/rs6739171-hash/Chest_Disease_Prediction_System.git
cd Chest_Disease_Prediction_System
```

### 2. Create and Activate Virtual Environment
Using `uv`:
```powershell
uv venv --python 3.10
.\.venv\Scripts\activate
```
*(Or standard Python):*
```powershell
python -m venv .venv
.\.venv\Scripts\activate
```

### 3. Install Dependencies
```powershell
uv add -r requirements.txt
# or
pip install -r requirements.txt
```

---

## 🏃 How to Run

### Run the Full Pipeline:
```powershell
python main.py
```

### Run an Individual Stage:
```powershell
# Stage 1: Data Ingestion
python src/cnnClassifier/pipeline/stage_01_data_ingestion.py

# Stage 2: Prepare Base Model
python src/cnnClassifier/pipeline/stage_02_prepare_basemodel.py

# Stage 3: Model Training
python src/cnnClassifier/pipeline/stage_03_training.py

# Stage 4: Model Evaluation
python src/cnnClassifier/pipeline/stage_04_model_evaluation.py
```

---

## 📊 MLflow Experiment Tracking

Experiments, parameters, and metrics are logged remotely to DagsHub:
- **DagsHub MLflow Dashboard**: [https://dagshub.com/rs6739171-hash/Chest_Disease_Prediction_System.mlflow](https://dagshub.com/rs6739171-hash/Chest_Disease_Prediction_System.mlflow)
- **Local UI** (optional):
  ```powershell
  mlflow ui
  ```
  Then open `http://localhost:5000` in your browser.
