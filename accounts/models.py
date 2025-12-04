from django.db import models
from django.contrib.auth.hashers import make_password, check_password

class Gym(models.Model):
    gym_id = models.AutoField(primary_key=True)
    gym_name = models.CharField(max_length=100)
    location = models.CharField(max_length=255, null=True, blank=True)
    contact_number = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(max_length=100, null=True, blank=True)
    
    class Meta:
        db_table = 'Gym'
        managed = False 
    def __str__(self):
        return self.gym_name


class Member(models.Model):
    member_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(max_length=100, unique=True)
    password = models.CharField(max_length=255)
    age = models.IntegerField(null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    join_date = models.DateField()
    
    class Meta:
        db_table = 'Member'
        managed = False  
    
    def set_password(self, raw_password):
        self.password = make_password(raw_password)
    
    def check_password(self, raw_password):
        return check_password(raw_password, self.password)
    
    def save(self, *args, **kwargs):

        if self.password and not self.password.startswith('pbkdf2_sha256'):
            self.password = make_password(self.password)
        super().save(*args, **kwargs)
    

    def __str__(self):
        return self.name


class Trainer(models.Model):
    trainer_id = models.AutoField(primary_key=True)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, db_column='gym_id')
    name = models.CharField(max_length=100)
    email = models.EmailField(max_length=100, unique=True)
    password = models.CharField(max_length=255)
    specialization = models.CharField(max_length=100, null=True, blank=True)
    
    class Meta:
        db_table = 'Trainer'
        managed = False  
    
    def set_password(self, raw_password):
        self.password = make_password(raw_password)
    
    def check_password(self, raw_password):
        return check_password(raw_password, self.password)
    
    def save(self, *args, **kwargs):

        if self.password and not self.password.startswith('pbkdf2_sha256'):
            self.password = make_password(self.password)
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.name


class Membership(models.Model):

    member_id = models.IntegerField()
    gym_id = models.IntegerField()
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=20)
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    class Meta:
        db_table = 'Membership'
        managed = False
    
    def get_member(self):
        return Member.objects.get(member_id=self.member_id)
    
    def get_gym(self):
        return Gym.objects.get(gym_id=self.gym_id)
    
    def __str__(self):
        try:
            return f"{self.get_member().name} - {self.get_gym().gym_name}"
        except:
            return f"Membership {self.member_id} - {self.gym_id}"