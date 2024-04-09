from .models import Classifier, Dataset, DatasetAttributes, UserSensor
from votingClassifier import VotingClassifier
from subscriberMQTT import subscriberMQTT
from paho.mqtt import client as mqtt_client
import pickle
import json
import os
import csv
import preprocessing

class Notifier:
    '''
    Implementa todo o processo desde a subscrição a tópicos até ao processamento
    de dados e envio de notificações para os respetivos canais.

    Argumentos:
    - "ip", do servidor MQTT
    - "port", do servidor MQTT
    '''

    def __init__(self, ip, port=1883):
        self.ids_file = ids_file
        self.voting = VotingClassifier()
        self.subs = []
        self.ip = ip
        self.port = port

    def new_dataset(self, path):
        Dataset.objects.all().delete()
        new_instance = Dataset(path=path)




        new_instance.save()

        
    def add_classifier(self, classifier, parameters):
        instances = Dataset.objects.all() # Retrieve all rows where name is "John"

        path = instances[0].path

        Dataset=pickle.load(open(path,'rb'))
        X = Dataset['X']
        y = Dataset['y']

        self.voting(classifier,parameters, X, y)
    
    def add_subscriber(self, idSensor, email, location):
        
        # Create an instance of MyModel
        new_instance = UserSensor(idSensor=idSensor, email=email, location=location)

        # Save the instance to the database
        new_instance.save()

    def add_subscriber(self, idSensor, email, location):
        self.stopListening()
        # Create an instance of MyModel
        new_instance = UserSensor(idSensor=idSensor, email=email, location=location)

        # Save the instance to the database
        new_instance.save()
        self.startListening()
    
    def delete_subscriber(self, idSensor, email, location):
        self.stopListening()
        UserSensor.objects.filter(idSensor=idSensor, email=email, location=location).delete()
        self.startListening()

    
    def connect_mqtt(self) -> mqtt_client:
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                print("Connected to MQTT Broker!")
            else:
                print("Failed to connect, return code %d\n", rc)
    
        client = mqtt_client.Client('Notifier')
        # client.username_pw_set(username, password)
        client.on_connect = on_connect
        client.connect(self.ip, self.port)
        return client

    def startListening(self):

        ids_values = UserSensor.objects.values_list('idUser', flat=True).distinct()
        
        self.subs = []

        # Loop through all instances and print their attributes
        for idUser in ids:
            instance = UserSensor.objects.filter(idUser=idUser)[0]
            self.subs.append(subscriberMQTT('moveID/subscriber' + instance.location + idUser , self.ip, self.port))
            
        for sub in self.subs:
            sub.run()

        
                
    def stopListening(self):
        for sub in self.subs:
            sub.stop()

        self.subs = []
    


    def publish(self,client, id):
        msg_count = 1
        while True:
            time.sleep(1)
            msg = f"messages: {msg_count}"
            result = client.publish('Notification', 'Alerta '+ id)
            # result: [0, 1]
            status = result[0]
            if status == 0:
                print(f"Send `{msg}` to topic `{topic}`")
            else:
                print(f"Failed to send message to topic {topic}")
            msg_count += 1
            if msg_count > 5:
                break

    def getData(self, file):

        data = {}
        with open(file, 'r') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)  # Pula o cabeçalho
            for row in reader:
                for i in range(len(row)):
                    my_float_list =[]
                    for x in row[i].split('_'):
                        if(x != ''):
                            my_float_list.append(float(x))
                    data[header[i]] = { 'x' : my_float_list[0], 'y' : my_float_list[1], 'z' : my_float_list[2]}

        return data

    def classify(self, data):
        windowed = preprocessing.windowed_data(data, 6)
        calculated = preprocessing.calculate_statistics(windowed)
        matrix = preprocessing.to_matrix(calculated)

        return self.voting.predict(matrix)

        
    
    
    def run(self):
        self.client = self.connect_mqtt()
        while True:
            
            for sub in self.subs:
                data = self.getData(sub.csv_file)
                if data.keys() == 6:
                    if self.classify(data):
                        client.loop_start()
                        self.publish(client, sub.topic)
                        client.loop_stop()

    