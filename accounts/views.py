from django.shortcuts import render, redirect
from django.contrib import messages
from .models import Member, Trainer

def login_select(request):
    """Landing page to select login type"""
    return render(request, 'login_select.html')


def member_login(request):
    """Handle member login"""
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            member = Member.objects.get(email=email)
            if member.check_password(password):
                # Store member info in session
                request.session['user_id'] = member.member_id
                request.session['user_type'] = 'member'
                request.session['user_name'] = member.name
                messages.success(request, f'Welcome back, {member.name}!')
                return redirect('member_dashboard')
            else:
                messages.error(request, 'Invalid email or password')
        except Member.DoesNotExist:
            messages.error(request, 'Invalid email or password')
    
    return render(request, 'member_login.html')


def trainer_login(request):
    """Handle trainer login"""
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            trainer = Trainer.objects.get(email=email)
            if trainer.check_password(password):
                # Store trainer info in session
                request.session['user_id'] = trainer.trainer_id
                request.session['user_type'] = 'trainer'
                request.session['user_name'] = trainer.name
                messages.success(request, f'Welcome back, {trainer.name}!')
                return redirect('trainer_dashboard')
            else:
                messages.error(request, 'Invalid email or password')
        except Trainer.DoesNotExist:
            messages.error(request, 'Invalid email or password')
    
    return render(request, 'trainer_login.html')


def member_dashboard(request):
    """Member dashboard view"""
    # Check if user is logged in as member
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    member = Member.objects.get(member_id=member_id)
    
    # Get active membership to display gym info
    membership = member.get_active_membership()
    
    context = {
        'member': member,
        'membership': membership,
    }
    return render(request, 'member_dashboard.html', context)


def trainer_dashboard(request):
    """Trainer dashboard view"""
    # Check if user is logged in as trainer
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    trainer = Trainer.objects.select_related('gym').get(trainer_id=trainer_id)
    
    context = {
        'trainer': trainer,
    }
    return render(request, 'trainer_dashboard.html', context)


def logout(request):
    """Handle logout for both member and trainer"""
    request.session.flush()
    messages.success(request, 'You have been logged out successfully')
    return redirect('login_select')