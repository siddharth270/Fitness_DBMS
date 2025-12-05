from django.contrib import admin
from django.urls import path, include
from . import views


urlpatterns = [

    path('trainer/plans/', views.trainer_plan_list, name='trainer_plan_list'),
    path('trainer/plans/create/', views.create_workout_plan, name='create_workout_plan'),
    path('trainer/plans/<int:plan_id>/', views.trainer_plan_detail, name='trainer_plan_detail'),
    path('trainer/plans/<int:plan_id>/add-exercise/', views.add_exercise_to_plan, name='add_exercise_to_plan'),
    path('trainer/plans/<int:plan_id>/delete/', views.delete_workout_plan, name='delete_workout_plan'),
    path('member/plans/', views.member_plan_list, name='member_plan_list'),
    path('member/plans/<int:plan_id>/', views.member_plan_detail, name='member_plan_detail')
    
]