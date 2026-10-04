from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {
        "message": "Hello from Cody's DevSecOps lab!",
        "status": "healthy",
        "version": "2.0"
    }

@app.route("/health")
def health():
    return {
        "status": "ok"
    }