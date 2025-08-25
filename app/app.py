
from flask import Flask, jsonify
import os, socket, time

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify(
        msg="Hello from EC2 + Docker (Free Tier)!",
        version=os.getenv("APP_VERSION", "dev"),
        hostname=socket.gethostname(),
        ts=int(time.time())
    )

@app.get("/health")
def health():
    return jsonify(status="ok")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "80")))
