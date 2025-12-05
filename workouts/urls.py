from django.urls import path
from . import views

urlpatterns = [
    path('', views.workout_list, name='workout_list'),
    path('new/', views.new_workout, name='new_workout'),
    path('active/', views.active_workout, name='active_workout'),
    path('start-from-plan/<int:plan_id>/', views.start_workout_from_plan, name='start_workout_from_plan'),
    path('search-exercises/', views.search_exercises, name='search_exercises'),
    path('add-exercise/<int:exercise_id>/', views.add_exercise_to_workout, name='add_exercise_to_workout'),
    path('log-set/<int:exercise_id>/', views.log_set, name='log_set'),
    path('delete-set/<int:set_id>/', views.delete_set, name='delete_set'),
    path('finish/', views.finish_workout, name='finish_workout'),
    path('cancel/', views.cancel_workout, name='cancel_workout'),
    path('<int:workout_id>/', views.workout_detail, name='workout_detail'),
]