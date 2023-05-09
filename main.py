from flask import Flask, render_template, request
from segno import helpers

import uuid
import segno

app = Flask(__name__)
scale = 10

@app.route('/')
def home():
    return render_template('index.html')

# Wifi

@app.route('/wifi', methods=['GET'])
def show_wifi_page():
    return render_template('qr-code-wifi.html')

@app.route('/wifi', methods=['POST'])
def create_wifi_code():
    ssid = request.form.get('ssid')
    password = request.form.get('password')
    security = request.form.get('security')

    # Hier kannst du die erhaltenen Daten weiterverarbeiten

    wifi_settings = {
        "ssid": ssid,
        "password": password,
        "security": security,
    }
    qrcode = helpers.make_wifi(**wifi_settings)
    guid = str(uuid.uuid4())
    path = "static/qrcodes/" + guid + ".png"
    qrcode.save(path, scale=scale)

    return render_template('show.html', path=path)

    # return 'Danke für die Einsendung! <img src="wificode.png"/ >'

# Contact

@app.route('/contact', methods=['GET'])
def show_address_page():
    return render_template('qr-code-contact.html')

@app.route("/contact", methods=['POST'])
def create_address_qrcode():
    name = request.form.get('name')
    email = request.form.get('email')
    url = request.form.get('url')
    phone = request.form.get('phone')

    qrcode = helpers.make_mecard(
        name=name,
        email=email,
        url=url,
        phone=phone,
    )
    guid = str(uuid.uuid4())
    path = "static/qrcodes/" + guid + ".png"
    qrcode.save(path, scale=scale)
    return render_template('show.html', path=path)

# URL

@app.route('/url', methods=['GET'])
def show_url_page():
    return render_template('qr-code-url.html')

@app.route("/url", methods=['POST'])
def create_url_qrcode():
    url = request.form.get('url')
    qrcode = segno.make(url)
    guid = str(uuid.uuid4())
    path = "static/qrcodes/" + guid + ".png"
    qrcode.save(path, scale=scale)
    return render_template('show.html', path=path)

@app.route('/about')
def about():
    return render_template('about.html')

if __name__ == '__main__':
    app.run()
