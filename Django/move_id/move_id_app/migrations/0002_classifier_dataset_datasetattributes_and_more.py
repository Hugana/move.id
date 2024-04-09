# Generated by Django 5.0.3 on 2024-04-08 16:54

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('move_id_app', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Classifier',
            fields=[
                ('name', models.CharField(max_length=255, primary_key=True, serialize=False)),
                ('path', models.CharField(max_length=255)),
                ('score', models.FloatField(max_length=10)),
            ],
        ),
        migrations.CreateModel(
            name='Dataset',
            fields=[
                ('path', models.CharField(max_length=255, primary_key=True, serialize=False)),
            ],
        ),
        migrations.CreateModel(
            name='DatasetAttributes',
            fields=[
                ('atr', models.CharField(max_length=255, primary_key=True, serialize=False)),
            ],
        ),
        migrations.RemoveField(
            model_name='patient',
            name='assigned_nurse',
        ),
        migrations.RemoveField(
            model_name='patient',
            name='id',
        ),
        migrations.AddField(
            model_name='patient',
            name='nif',
            field=models.IntegerField(default=0, primary_key=True, serialize=False),
        ),
        migrations.CreateModel(
            name='PatientSensor',
            fields=[
                ('idSensor', models.CharField(max_length=50, primary_key=True, serialize=False)),
                ('nif', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='move_id_app.patient')),
            ],
        ),
        migrations.CreateModel(
            name='UserSensor',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('location', models.CharField(max_length=255)),
                ('idSensor', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='move_id_app.patientsensor')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]