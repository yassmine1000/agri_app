import tensorflow as tf
model = tf.keras.models.load_model('src/best_model.keras')
model.summary()
