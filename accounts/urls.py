from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_select, name='login_select'),
    path('member/login/', views.member_login, name='member_login'),
    path('trainer/login/', views.trainer_login, name='trainer_login'),
    path('member/dashboard/', views.member_dashboard, name='member_dashboard'),
    path('trainer/dashboard/', views.trainer_dashboard, name='trainer_dashboard'),
    path('logout/', views.logout, name='logout'),

]