from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('accounts.urls')),
    path('workouts/', include('workouts.urls')),
    path('appointments/', include('appointments.urls')),
    path('workout_plans/', include('workout_plans.urls')),
    
]