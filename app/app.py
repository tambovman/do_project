import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return {"app": "devops-demo", "status": "running"}

@app.route("/health")
def health():
    if os.getenv("FORCE_HEALTH_FAIL") == "1":
        return {"status": "broken"}, 500

    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)