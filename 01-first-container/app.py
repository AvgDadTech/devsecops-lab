from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {
        "message": "Hello from Cody's automated DevSecOps pipeline!",
        "status": "healthy",
        "version": "3.0"
    }

@app.route("/health")
def health():
    return {
        "status": "ok"
    }