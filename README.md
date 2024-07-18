# move.id - Outlier Detection in Human Activity Data

## Introduction
Final project of Informatics and Multimedia Engineering BSc.

The project titled "move.id - Outlier Detection in Human Activity Data" aims to leverage data from bands (in our case we used a phone) that are in patients at risk of falling.

By acquiring this data from these sensors, the project seeks to build representative datasets of both standard and non-standard movements. Utilizing these datasets, the project will create classifiers capable of detecting outlier movements. When such out-of-the-ordinary movements are identified by these classifiers, notifications will be sent to predefined users such as healthcare teams, via a phone application, to alert them of anomalies in the patients' movement.

This system intends to enhance patient monitoring and provide timely alerts for potential issues detected through the analysis of sensor data.

## Table of Contents 
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Project Structure](#project-structure)
- [About](#about)
- [Contacts](#contacts)

## Installation

To set up the project locally, follow these steps:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/Hugana/move.id-
    ```

2. **Navigate to the project directory**:
    ```sh
    cd move.id
    ```

3. **Activate the existing virtual environment in the Django directory**:
    ```sh
    cd Django
    ```
    - On Windows:
        ```sh
        .\virtual\Scripts\activate
        ```
4. **Install the required dependencies within the virtual environment**:
    - Using the `requirements.txt` file:
        ```sh
        pip install -r requirements.txt
        ```
    - Or install the following packages individually:
        ```sh
        pip install django djangorestframework paho-mqtt psycopg2 pandas adtk
        ```

Now everything in the Django back office is configured. Let's proceed to the Flutter installation.

For the Flutter installation you need: 
1. Android Studio
2. VisualStudioCode

Once Android Studio is installed, go to open it, then go to tools>SDK Manager then go to Language & Frameworks>Android SDK>SDK Tools and tick the box that 
says "Android SDK Command-line Tools"

Then install the flutter extension the VSCode.

And finally install flutter trough this link https://docs.flutter.dev/get-started/install/windows/mobile?tab=download

With Flutter, and django all set up its time for the database, PostgreSQL.
I recommend following this youtube video https://www.youtube.com/watch?v=unFGJhIvHU4&t=381s
and set up the database like he sets up, in our case the database as this configuration:
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME':'move_id',
        'USER':'admin',
        'PASSWORD':'admin',
        'HOST': 'localhost'
    }
}
```

## Usage

For the usage somethings are still going to be configurated, mainly the database table migrations and the admin super user.

Let's fist start with the creation of the super user in Django.
To create the super user you need to run the following command in the terminal:

```sh
 python manage.py createsuperuser
```
After creating this super user you need to migrate the models into the database using the followig commands:
Create:

```sh
 python manage.py makemigrations
```
Apply:
```
sh
python manage.py makemigrations
```

Upon creating the database structure and the super admin, run the server with the command,access the localhost and login with the superuser credentials:
```
sh
python manage.py runserver
```

## Features

The "move.id - Outlier Detection in Human Activity Data" project includes several features to enhance patient monitoring and ensure timely alerts for potential issues detected through the analysis of sensor data:

### 1. Data Acquisition from Sensors
- Collect data from sensors (e.g., smartphones) attached to patients at risk of falling.
- Gather a variety of movement data to build comprehensive datasets representing both normal and abnormal activities.

### 2. Data Processing and Cleaning
- Preprocess and clean the raw data to ensure accuracy and consistency.

### 3. Machine Learning-Based Classification and Unsupervised Classification
- Utilize machine learning algorithms to build classifiers capable of distinguishing between standard and outlier movements.
- Train models on representative datasets to accurately detect abnormal movements.
- Utilizes ADTK library to classify outliers

### 4. Real-Time Outlier Detection
- Implement real-time detection of outlier movements using the trained classifiers.
- Monitor sensor data continuously to identify potential issues as they occur.

### 5. Notification and Classification System
- Send alerts to predefined users, such as healthcare teams, via a mobile application when outlier movements are detected.
- Ensure timely intervention and monitoring of patients based on the notifications received.
- Allows users to classify the notifications they received

### 6. User Management and Authentication
- Manage user accounts and permissions within the Django admin interface.
- Authenticate users to ensure secure access to the system and its features.

### 7. Integration with Flutter Mobile Application
- Provide a mobile interface for healthcare professionals to receive and manage alerts.
- Ensure seamless integration between the Django backend and the Flutter frontend.

### 8. Database Management with PostgreSQL
- Utilize PostgreSQL for robust and scalable database management.
- Store and manage large volumes of sensor data efficiently.

### 9. RESTful API with Django Rest Framework
- Implement RESTful API endpoints for data interaction between the backend and the mobile application.
- Ensure secure and efficient communication through the API.

### 10. Scalability and Extensibility
- Design the system to be scalable and extensible for future enhancements.
- Allow for easy integration of additional sensors, data types, and machine learning models.

These features collectively provide a comprehensive solution for detecting and managing outlier movements in patients, enhancing their safety and improving healthcare outcomes.


## Project Structure

The "move.id - Outlier Detection in Human Activity Data" project is organized into several directories and files, each serving a specific purpose. Below is an overview of the project structure:


1. **Django Directory**:
    - `manage.py`: Script to manage the Django project.
    - `virtual/`: Directory containing the virtual environment.
    - `requirements.txt`: File listing the Python dependencies.
    - `move_id/`: Main Django project directory.
        - `settings.py`: Configuration settings for the Django project.
        - `urls.py`: URL configuration for the project.
        - `wsgi.py`: WSGI application entry point.
        - `asgi.py`: ASGI application entry point.
    - `move_id_app/`: Directory containing Django applications.
        - `migrations/`: Database migrations.
        - `models.py`: Data models.
        - `views.py`: Views for handling requests.
        - `admin.py`: Admin interface configuration.
        - `urls.py`: URL configuration for the sensors app.
        - `tests.py`: Tests for the sensors app.
        - `notifier.py`: Main class, the only one that needs to be instantiated for the main process to work.
        - `sensordatautils.py`: Funtions for sensor data management.
        - `subscriberMQTT.py`:  Class responsible for the MQTT communication.
        - `votingClassifier.py`: Class to support the entire process of voting by the classification models.
        - `classifiers/`: Application for user management.
            - `classifiers.py`: Abstract Classes for the classifiers.
            - `histogram_based_outlier_detection.py`: Histogram-based outlier detection classifier implementation.
            - `isolation_forest_classifier.py`: Isolation Forest classifier implementation.
            - `level_shift.py`: ADTK LevelShiftAD classifier.
            - `oneclassSVMclassifier.py`: OneClassSVM classifier.
            - `outlier_detection.py`: ADTK OutlierDetector classifier implementation.
            - `quantile.py`: ADTK QuantileAD classifier.
        - `dataset/`: Folder to store datasets.
        - `migrations/`: Folder to store database migrations.
        - `models/`: Folder to store the classification models

2. **Flutter Directory**:
    - `android/` and `ios/`: Platform-specific files for Android and iOS.
    - `lib/`: Main directory for Dart code.
        - `main.dart`: Entry point for the Flutter application.
        - `models/`: Data models for the Flutter application.
        - `screens/`: UI screens for the application.
        - `utils/`: Code used to simplify the flutter implemention.
        - `Notification/`: Handles the notification system.
    - `pubspec.yaml`: File listing the Flutter project dependencies.

3. **Root Directory**:
    - `README.md`: Main documentation file for the project.



## About

This project, "move.id - Outlier Detection in Human Activity Data," was developed by Hugo Ferreira, João Pereira, and João Alves. They are students at the Instituto Superior de Engenharia de Lisboa (ISEL) in Lisbon, Portugal, pursuing a degree in Licenciatura em Engenharia Informática e Multimédia.

The team's goal is to enhance patient monitoring by detecting outlier movements using data from sensors. This system aims to provide timely alerts for potential issues, improving the safety and well-being of patients at risk of falling.

## Contacts

- Hugo Ferreira 
  - [LinkedIn](https://www.linkedin.com/in/hugo-ferreira-bab142206/)
  - Email: [hugo.dn.ferreira@gmail.com](mailto:hugo.dn.ferreira@gmail.com)

- Joao Alves
  - [LinkedIn](www.linkedin.com/in/joão-alves-0a7110240)
  - Email: [joao.p.alves.2012@gmail.com](mailto:joao.p.alves.2012@gmail.com)
 
- Joao Alves
  - [LinkedIn]( https://www.linkedin.com/in/joão-pereira-040b3a212/)
  - Email: [joao.pereira197606@gmail.com](mailto:joao.pereira197606@gmail.com)


    






