# Generated by Django 5.0.3 on 2024-03-16 14:59

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Nurse',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fname', models.CharField(max_length=50)),
                ('lname', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=100)),
                ('device_token', models.CharField(max_length=200)),
            ],
        ),
        migrations.CreateModel(
            name='Patiente',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fname', models.CharField(max_length=50)),
                ('lname', models.CharField(max_length=100)),
                ('age', models.IntegerField()),
                ('gender', models.CharField(max_length=30)),
            ],
        ),
        migrations.CreateModel(
            name='Alert',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField(auto_now_add=True)),
                ('message', models.CharField(max_length=200)),
                ('handled', models.BooleanField(default=False)),
                ('nurse', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='move_id_app.nurse')),
                ('patiente', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='move_id_app.patiente')),
            ],
        ),
    ]
