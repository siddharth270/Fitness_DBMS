from django.db import models

class Exercise(models.Model):
    exercise_id = models.AutoField(primary_key=True)
    exercise_name = models.CharField(max_length=100, unique=True)
    category = models.CharField(max_length=50)
    target_muscle_group = models.CharField(max_length=100, null=True, blank=True)
    
    class Meta:
        db_table = 'Exercise'
        managed = False
    
    def __str__(self):
        return self.exercise_name


class Workout(models.Model):
    workout_id = models.AutoField(primary_key=True)
    member_id = models.IntegerField()
    gym_id = models.IntegerField()
    plan_id = models.IntegerField(null=True, blank=True)
    date = models.DateField()
    duration = models.IntegerField(null=True, blank=True)  # in minutes
    calories_burned = models.IntegerField(null=True, blank=True)
    
    class Meta:
        db_table = 'Workout'
        managed = False
        ordering = ['-date']
    
    def get_member(self):
        from accounts.models import Member
        return Member.objects.get(member_id=self.member_id)
    
    def get_gym(self):
        from accounts.models import Gym
        return Gym.objects.get(gym_id=self.gym_id)
    
    def get_sets(self):
        """Get all sets for this workout"""
        return Set.objects.filter(workout_id=self.workout_id)
    
    def __str__(self):
        return f"Workout {self.workout_id} - {self.date}"


class Set(models.Model):
    set_id = models.AutoField(primary_key=True)
    workout_id = models.IntegerField()
    exercise_id = models.IntegerField()
    no_of_reps = models.IntegerField()
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    class Meta:
        db_table = 'Set'
        managed = False
    
    def get_exercise(self):
        return Exercise.objects.get(exercise_id=self.exercise_id)
    
    def __str__(self):
        return f"Set {self.set_id}"