from django.urls import path
from . import views

urlpatterns = [
    path('', views.appointment_list, name='appointment_list'),
    path('book/', views.book_appointment, name='book_appointment'),
    path('cancel/<int:appointment_id>/', views.cancel_appointment, name='cancel_appointment'),
    path('trainer/<int:trainer_id>/', views.trainer_detail, name='trainer_detail'),
    path('trainer/appointments/', views.trainer_appointments, name='trainer_appointments'),
    path('trainer/schedule/', views.trainer_schedule, name='trainer_schedule'),
    path('trainer/clients/', views.trainer_clients, name='trainer_clients'),
    path('<int:appointment_id>/delete/', views.delete_appointment, name='delete_appointment'),
]