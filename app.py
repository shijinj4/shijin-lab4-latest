from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return 'Shijin Joseph - Hello, World!'

if __name__ == '__main__':
    # Run the application on http://0.0.0.0:8080
    # Setting the host to '0.0.0.0' makes the server accessible from other machines on the network.
    app.run(host='0.0.0.0', port=5000, debug=True)
