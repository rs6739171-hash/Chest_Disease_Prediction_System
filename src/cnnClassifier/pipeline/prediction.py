import numpy as np
import tensorflow as tf
import os


class PredictionPipeline:
    def __init__(self, filename):
        self.filename = filename

    def predict(self):
        # Load model from artifacts
        model_path = os.path.join("artifacts", "training", "model.h5")
        if not os.path.exists(model_path):
            model_path = os.path.join("artifacts", "prepare_base_model", "base_model_updated.h5")
        
        model = tf.keras.models.load_model(model_path)

        imagename = self.filename
        test_image = tf.keras.preprocessing.image.load_img(imagename, target_size=(224, 224))
        test_image = tf.keras.preprocessing.image.img_to_array(test_image)
        test_image = np.expand_dims(test_image, axis=0)
        test_image = test_image / 255.0
        raw_pred = model.predict(test_image)
        result = np.argmax(raw_pred, axis=1)
        confidence = float(np.max(raw_pred)) * 100

        if result[0] == 1:
            prediction = 'Normal'
        else:
            prediction = 'Adenocarcinoma Cancer'
        return [{"image": prediction, "confidence": round(confidence, 2)}]

