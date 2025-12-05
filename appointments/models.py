from django.db import models

class Appointment(models.Model):
    appointment_id = models.AutoField(primary_key=True)
    trainer_id = models.IntegerField()
    member_id = models.IntegerField()
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    status = models.CharField(max_length=20)
    
    class Meta:
        db_table = 'Appointment'
        managed = False
        ordering = ['-start_time']
    
    def get_trainer(self):
        from accounts.models import Trainer
        return Trainer.objects.get(trainer_id=self.trainer_id)
    
    def get_member(self):
        from accounts.models import Member
        return Member.objects.get(member_id=self.member_id)
    
    def __str__(self):
        return f"Appointment {self.appointment_id}"