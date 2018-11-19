from flask import Flask, request
app = Flask(__name__)


@app.route('/')
def index():
    env = request.environ
    return f"Flask is Dockerized! @ {env.get('HTTP_X_REAL_IP') or env.get('REMOTE_ADDR')}"


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
