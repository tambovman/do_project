import os
from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "devops_demo_http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint"]
)


@app.route("/")
def index():
    REQUEST_COUNT.labels(method="GET", endpoint="/").inc()
    return {"app": "devops-demo", "status": "running"}


@app.route("/health")
def health():
    REQUEST_COUNT.labels(method="GET", endpoint="/health").inc()

    if os.getenv("FORCE_HEALTH_FAIL") == "1":
        return {"status": "broken"}, 500

    return {"status": "healthy"}


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)