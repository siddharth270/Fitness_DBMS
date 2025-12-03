from django.urls import path
from . import views

urlpatterns = [
    path('', views.workout_list, name='workout_list'),
    path('new/', views.new_workout, name='new_workout'),
    path('<int:workout_id>/', views.workout_detail, name='workout_detail'),
    path('add-exercise/', views.add_exercise, name='add_exercise'),
    path('log-set/<int:exercise_id>/', views.log_set, name='log_set'),
    path('complete/', views.complete_workout, name='complete_workout'),
]