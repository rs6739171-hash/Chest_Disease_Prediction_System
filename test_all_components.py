import os
import glob
import base64
import json
from pathlib import Path
import tensorflow as tf

from cnnClassifier import logger
from cnnClassifier.constants import CONFIG_FILE_PATH, PARAMS_FILE_PATH
from cnnClassifier.utils.common import (
    read_yaml, create_directories, save_json, load_json, decodeImage, encodeImageIntoBase64
)
from cnnClassifier.config.configuration import ConfigurationManager
from cnnClassifier.entity.config_entity import (
    DataIngestionConfig, PrepareBaseModelConfig, TrainingConfig, EvaluationConfig
)
from cnnClassifier.pipeline.prediction import PredictionPipeline
from app import app


def test_01_utilities():
    print("\n--- [1/6] Testing Utilities ---")
    # create_directories
    test_dir = Path("artifacts/test_tmp")
    create_directories([test_dir], verbose=False)
    assert test_dir.exists(), "Directory creation failed"

    # save_json & load_json
    test_json = test_dir / "test.json"
    save_json(test_json, {"status": "ok", "accuracy": 0.95})
    loaded = load_json(test_json)
    assert loaded.status == "ok"
    assert loaded.accuracy == 0.95

    # decodeImage & encodeImageIntoBase64
    test_img = test_dir / "sample.txt"
    test_img.write_text("dummy-data")
    encoded = encodeImageIntoBase64(test_img)
    decoded_file = test_dir / "sample_decoded.txt"
    decodeImage(encoded.decode("utf-8"), str(decoded_file))
    assert decoded_file.read_text() == "dummy-data"

    # cleanup
    import shutil
    shutil.rmtree(test_dir)
    print(">>> Utilities test PASSED!")


def test_02_configuration_manager():
    print("\n--- [2/6] Testing ConfigurationManager ---")
    config_mgr = ConfigurationManager()

    # 1. Ingestion Config
    ingestion_cfg = config_mgr.get_data_ingestion_config()
    assert isinstance(ingestion_cfg, DataIngestionConfig)
    assert ingestion_cfg.source_URL != ""
    assert Path(ingestion_cfg.local_data_file).name == "data.zip"

    # 2. Base Model Config
    base_model_cfg = config_mgr.get_prepare_base_model_config()
    assert isinstance(base_model_cfg, PrepareBaseModelConfig)
    assert base_model_cfg.params_classes == 2
    assert list(base_model_cfg.params_image_size) == [224, 224, 3]

    # 3. Training Config
    train_cfg = config_mgr.get_training_config()
    assert isinstance(train_cfg, TrainingConfig)
    assert train_cfg.params_epochs > 0
    assert train_cfg.params_batch_size > 0

    # 4. Evaluation Config
    eval_cfg = config_mgr.get_evaluation_config()
    assert isinstance(eval_cfg, EvaluationConfig)
    assert "dagshub.com" in eval_cfg.mlflow_uri
    print(">>> ConfigurationManager test PASSED!")


def test_03_artifacts_and_dataset():
    print("\n--- [3/6] Testing Artifacts & Dataset Integrity ---")
    data_dir = Path("artifacts/data_ingestion/Chest-CT-Scan-data")
    assert data_dir.exists(), "Dataset directory does not exist"
    
    adeno_images = list((data_dir / "adenocarcinoma").glob("*.png"))
    normal_images = list((data_dir / "normal").glob("*.png"))
    assert len(adeno_images) > 0, "No adenocarcinoma images found"
    assert len(normal_images) > 0, "No normal images found"
    print(f"Dataset verified: {len(adeno_images)} adenocarcinoma, {len(normal_images)} normal images.")

    # Check model artifacts
    base_model = Path("artifacts/prepare_base_model/base_model.h5")
    updated_model = Path("artifacts/prepare_base_model/base_model_updated.h5")
    trained_model = Path("artifacts/training/model.h5")
    assert base_model.exists(), "base_model.h5 missing"
    assert updated_model.exists(), "base_model_updated.h5 missing"
    assert trained_model.exists(), "model.h5 missing"
    print(">>> Artifacts and Dataset test PASSED!")


def test_04_prediction_pipeline():
    print("\n--- [4/6] Testing Prediction Pipeline ---")
    data_dir = Path("artifacts/data_ingestion/Chest-CT-Scan-data")
    test_images = list(data_dir.rglob("*.png"))
    assert len(test_images) > 0, "No images found for prediction test"

    sample_img = str(test_images[0])
    pipeline = PredictionPipeline(filename=sample_img)
    result = pipeline.predict()

    assert isinstance(result, list), "Prediction result must be a list"
    assert len(result) == 1, "Result must contain 1 dictionary"
    assert "image" in result[0], "Result dictionary must have 'image' key"
    assert result[0]["image"] in ["Normal", "Adenocarcinoma Cancer"]
    print(f"Inference output on {Path(sample_img).name}: {result}")
    print(">>> Prediction Pipeline test PASSED!")


def test_05_flask_web_app():
    print("\n--- [5/6] Testing Flask Web Application Routes ---")
    app.config["TESTING"] = True
    client = app.test_client()

    # 1. GET /
    response = client.get("/")
    assert response.status_code == 200
    assert b"Chest Disease Prediction System" in response.data
    print("GET / -> 200 OK")

    # 2. POST /predict
    data_dir = Path("artifacts/data_ingestion/Chest-CT-Scan-data")
    test_images = list(data_dir.rglob("*.png"))
    with open(test_images[0], "rb") as f:
        encoded_b64 = base64.b64encode(f.read()).decode("utf-8")

    res = client.post("/predict", json={"image": encoded_b64})
    assert res.status_code == 200
    json_data = res.get_json()
    assert isinstance(json_data, list)
    assert json_data[0]["image"] in ["Normal", "Adenocarcinoma Cancer"]
    print(f"POST /predict -> 200 OK, Response: {json_data}")
    print(">>> Flask Web Application test PASSED!")


if __name__ == "__main__":
    print("======================================================")
    print("       STARTING FULL COMPONENT FLOW TEST SUITE        ")
    print("======================================================")
    test_01_utilities()
    test_02_configuration_manager()
    test_03_artifacts_and_dataset()
    test_04_prediction_pipeline()
    test_05_flask_web_app()
    print("======================================================")
    print("   ALL 5 COMPONENT FLOW TESTS PASSED SUCCESSFULLY!    ")
    print("======================================================")
