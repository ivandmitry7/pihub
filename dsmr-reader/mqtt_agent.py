import paho.mqtt.client as mqttClient
import time
import json
import requests
import re

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to broker")
        global Connected  # Use global variable
        Connected = True  # Signal connection
    else:
        print("Connection failed")


def on_message(client, userdata, message):
    # try:
    #     print("Message received: " + re.sub(r"\"TS\":.*?,", "", message.payload.decode('utf-8')))
    # except Exception as e: 
    #     print(e)

    try:
        j = json.loads(re.sub(r"\"TS\":.*?,", "", message.payload.decode('utf-8')))
    except:
        print('error parsing json data')

    response = requests.post(
        'http://192.168.1.28:7777/api/v2/datalogger/dsmrreading',
        headers={'X-AUTHKEY': 'S9M8YBQHK7JT6LCGEWVYT2K3CU55OHXCPKOSCF70HVRM0NVWI4QQFK0G9CFY4FNA'},
        data={
            'electricity_currently_delivered': j['P1GATEWAY']['P1'],
            'electricity_currently_returned': 0,
            'electricity_delivered_1': j['P1GATEWAY']['T1'],
            'electricity_delivered_2': j['P1GATEWAY']['T2'],
            'electricity_returned_1': 0,
            'electricity_returned_2': 0,
            'extra_device_timestamp': j['Time'],
            'extra_device_delivered': j['P1GATEWAY']['GAS'],
            'timestamp': j['Time']
        }
    )

    # if response.status_code != 201:
    #     print('Error: {}'.format(response.text))
    # else:
    #     print('Success: {}'.format(json.loads(response.text)))


Connected = False  # global variable for the state of the connection

broker_address = "192.168.1.28"  # Broker address
port = 1883  # Broker port
user = ""  # Connection username
password = ""  # Connection password

client = mqttClient.Client("Python")  # create new instance
client.username_pw_set(user, password=password)  # set username and password
client.on_connect = on_connect  # attach function to callback
client.on_message = on_message  # attach function to callback

client.connect(broker_address, port=port)  # connect to broker

client.loop_start()  # start the loop

while Connected != True:  # Wait for connection
    time.sleep(0.1)

client.subscribe("tele/sonoffP1/SENSOR")

try:
    while True:
        time.sleep(1)

except KeyboardInterrupt:
    print("exiting")
    client.disconnect()
    client.loop_stop()
