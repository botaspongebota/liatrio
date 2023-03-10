from flask import Flask, jsonify
import time

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify(message='Automate all the things!', timestamp=int(time.time()))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

