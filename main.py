from flask import Flask, render_template, request
from segno import helpers

import uuid

app = Flask(__name__)
scale = 10

@app.route('/')
def home():
    return render_template('index.html')

    # return 'Willkommen auf meiner Website!'

@app.route('/create-wifi-qr-code', methods=['GET'])
def create_wifi_qrcode():
    return render_template('create-wifi-qr-code.html')

@app.route('/create-wifi-qr-code', methods=['POST'])
def submit():
    ssid = request.form.get('ssid')
    password = request.form.get('password')
    security = request.form.get('security')

    # Hier kannst du die erhaltenen Daten weiterverarbeiten

    wifi_settings = {
        "ssid": ssid,
        "password": password,
        "security": security,
    }
    wifi = helpers.make_wifi(**wifi_settings)
    guid = str(uuid.uuid4())
    path = "static/qrcodes/" + guid + ".png"
    wifi.save(path, scale=scale)

    return render_template('show.html', path=path)

    # return 'Danke für die Einsendung! <img src="wificode.png"/ >'

@app.route('/create-address-qr-code', methods=['GET'])
def create():
    return render_template('create-address-qr-code.html')

@app.route("/create-address-qr-code", methods=['POST'])
def create_address_qrcode():
    name = request.form.get('name')
    email = request.form.get('email')
    url = request.form.get('url')
    phone = request.form.get('phone')

    contact = helpers.make_mecard(
        name=name,
        email=email,
        url=url,
        phone=phone,
    )
    guid = str(uuid.uuid4())
    path = "static/qrcodes/" + guid + ".png"
    contact.save(path, scale=scale)
    return render_template('show.html', path=path)

@app.route('/about')
def about():
    return render_template('about.html')


if __name__ == '__main__':
    app.run()
