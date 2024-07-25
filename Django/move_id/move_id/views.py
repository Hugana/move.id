import json
from django.http import JsonResponse
from rest_framework.views import APIView
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from move_id_app.models import UserSensor
from move_id_app.models import Patient
from move_id_app.models import Sensor
from move_id_app.models import Location, SensorDataClassification

class RegisterAPI(APIView):

    def post(self,request):

        if request.method == 'POST':

            print("Entrou no Resgister")
            
            data = json.loads(request.body)
            first_name = data.get('first_name')
            last_name = data.get('last_name')
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')

            if User.objects.filter(email=email).exists():
                print("Email ja esta usado")
                return JsonResponse({'error': 'Email already in use'}, status=400)
      
            user = User.objects.create_user(username=username, email=email, password=password)
            user.first_name = first_name
            user.last_name = last_name
          
            user.save()

            return JsonResponse({'message': 'User created successfully'}, status=200)
        else:
            print("Erro no metodo")
            return JsonResponse({'error': 'Method not allowed'}, status=405)
        



class LoginAPI(APIView):

    def post(self,request):

        if request.method == 'POST':

            print("Entrou no Login")

            data = json.loads(request.body)

            email = data.get('email')
            password = data.get('password')

            user = User.objects.filter(email=email).first()
            if not user:
                return JsonResponse({'error': 'User with this email does not exist'}, status=404)
            
            authenticated_user = authenticate(username=user.username, password=password)
            if not authenticated_user:
                return JsonResponse({'error': 'Incorrect password'}, status=401)
            
            return JsonResponse({'message': 'Login successful', 'user_id': user.id}, status=200)

class ListenersAPI(APIView):

    def post(self, request):

        data = json.loads(request.body)

        print(data)

        email = data.get('email')

        print('email: ' + email)

        user = User.objects.filter(email=email).first()
        
        print("user" + str(user.id))
        print('antes')
        if not user:
                print("1")
                return JsonResponse({'error': 'User with this email does not exist'}, status=404)

        print('antes')
        
        try:
            print("user:"+str(user.id))
            usersensors = UserSensor.objects.filter(user=user).all()
            data = [{'id_sensor':str(us.sensor.id_sensor),'id_location': str(us.sensor.location.id)} for us in usersensors]

            print(data)

            return JsonResponse({'listeners': data}, status=200)
        except Exception as e:
            return JsonResponse({'error': 'Couldnt query the table'}, status=404)

    

class NotifierAPI(APIView):

    def post(self, request):
        if request.method == 'POST':

            print("Entrou no post addNotifier")

            data = json.loads(request.body)

            email = data.get('email')
            idSensor = data.get('idSensor')
            idLocation = data.get('idLocation')
            
            user = User.objects.filter(email=email).first()

            if not user:
                #print("1")
                return JsonResponse({'error': 'User with this email does not exist'}, status=404)


            sensor = Sensor.objects.filter(id_sensor=idSensor).first()
            if not sensor:
                
                return JsonResponse({'error': 'Sensor with this idSensor does not exist'}, status=404)
            
            print(idSensor)

            location = Location.objects.filter(id=idLocation).first()
            print(idLocation)
            if not location:

                #print("3")
                return JsonResponse({'error': 'Location with this id does not exist'}, status=404)

            print(idLocation)

            user_sensor = UserSensor(user=user, sensor=sensor)
            user_sensor.save()


            return JsonResponse({'message': 'Notifier added succesfully'}, status=200)
    
    

    def delete(self, request):
            if request.method == 'DELETE':

                print("Entrou no delete addNotifier")

                data = json.loads(request.body)

                email = data.get('email')
                idSensor = data.get('idSensor')

                user = User.objects.filter(email=email).first()
                if not user:
                    return JsonResponse({'error': 'User with this email does not exist'}, status=404)

                sensor = Sensor.objects.filter(id_sensor=idSensor).first()
                if not sensor:
                    return JsonResponse({'error': 'Sensor with this idSensor does not exist'}, status=404)

                try:
                    user_sensor = UserSensor.objects.get(user=user, id_sensor=sensor)
                    user_sensor.delete()
                    return JsonResponse({'message': 'Notifier removed successfully'}, status=200)
                except UserSensor.DoesNotExist:
                    return JsonResponse({'error': 'Notifier does not exist'}, status=404)


class LocationGetterAPI(APIView):

    def get(self, request):
        print("Entrou no location Getter")
        try:
            locations = Location.objects.all()
            locations_data = [{'name': str(location.name), 'id': str(location.id)} for location in locations]

            print(locations_data)
            return JsonResponse({'locations': locations_data}, status=200)
        except Exception as e:
            return JsonResponse({'error': 'Couldnt query the table'}, status=404)


class ClassificationAPI(APIView):
    def post(self, request):
        if request.method == 'POST':
           
            data = json.loads(request.body)

            email = data.get('email')
            id = data.get('id')
            classification = data.get('classification')
            
            user = User.objects.filter(email=email).first()

            if not user:
                #print("1")
                return JsonResponse({'error': 'User with this email does not exist'}, status=404)


            notification = SensorDataClassification.objects.filter(id=id, user=user).first()
            if not notification:
                
                return JsonResponse({'error': 'Notification with this id does not exist'}, status=404)
            

            notification.classification = bool(classification)
            notification.save()


            return JsonResponse({'message': 'Classification added succesfully'}, status=200)

    
class NotificationHistoryAPI(APIView):
    def post(self, request):
        
        data = json.loads(request.body)

        email = data.get('email')

        user = User.objects.filter(email=email).first()

        if not user:
            return JsonResponse({'error': 'User with this email does not exist'}, status=404)
        

        try:
            notifications = SensorDataClassification.objects.filter(user=user, classification=None).all()

            data = []

            for notification in notifications:
                idSensor = notification.sensor.id_sensor

                sensor = Sensor.objects.filter(id_sensor=idSensor).first()
                if not sensor:
                    print("NO SENSOR")
                    return JsonResponse({'error': 'Sensor with this id does not exist'}, status=404)
                
                patient = Patient.objects.filter(nif=sensor.patient.nif).first()
                if not patient:
                    print("NO PATIENT")
                    return JsonResponse({'error': 'Patient with this NIF does not exist'}, status=404)

                location = Location.objects.filter(id=sensor.location.id).first()
                

                print(str(notification.id))
                print(str(notification.datetime))
                print(str(idSensor))
                print(str(patient.first_name))
                print(str(patient.last_name))
                print(str(patient.room))
                print(str(patient.bed))
                print(str(location.name))

                data.append({'id': str(notification.id), 
                'datetime': str(notification.datetime),
                'idSensor': str(idSensor), 
                'fname': str(patient.first_name), 
                'lname': str(patient.last_name),
                'room':str(patient.room), 
                'bed':str(patient.bed), 
                'location':str(location.name)})
                
                print("5")

            return JsonResponse({'notifications': data}, status=200)
        except Exception as e:
            print("EXCEPTION")
            return JsonResponse({'error': 'Couldnt query the table'}, status=404)
