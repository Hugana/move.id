# Generated by Django 5.0.3 on 2024-05-21 16:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('move_id_app', '0002_alter_sensordataclassification_classification'),
    ]

    operations = [
        migrations.AlterField(
            model_name='sensordataclassification',
            name='classification',
            field=models.BooleanField(default=None, null=True),
        ),
    ]
