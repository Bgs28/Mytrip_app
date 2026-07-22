<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Admin\HotelController;
use App\Http\Controllers\Admin\TrainController;
use App\Http\Controllers\Admin\BusController;
use App\Http\Controllers\Admin\BookingController;
use App\Http\Controllers\Admin\PromoController;

// Web Routes - Admin Panel


Route::prefix('admin')->name('admin.')->group(function () {

    // --- RUTE GUEST (Bisa diakses tanpa login / sebelum login) ---
    Route::middleware('guest')->group(function () {
        Route::get('/login', [AuthController::class, 'loginPage'])->name('login');
        Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
    });

    // --- RUTE PROTECTED (Wajib Login & Harus Role Admin) ---
    Route::middleware(['auth', 'admin'])->group(function () {
        
        // Dashboard Admin
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
        
        // CRUD Kelola User
        Route::resource('users', UserController::class);

        // CRUD Kelola Promo
        Route::resource('promo', PromoController::class);
        Route::post('/promo/{id}/toggle-active', [PromoController::class, 'toggleActive'])
            ->name('promo.toggleActive');

        // CRUD Kelola Hotel
        Route::resource('hotels', HotelController::class);

        // CRUD kelola Train
        Route::resource('trains', TrainController::class);
        
        // CRUD kelola Bus
        Route::resource('buses', BusController::class);

        // Route Kelola Booking Admin
        Route::get('/bookings', [BookingController::class, 'index'])->name('booking.index');
        Route::get('/bookings/{id}', [BookingController::class, 'show'])->name('booking.show');
        Route::patch('/bookings/{id}/status', [BookingController::class, 'updateStatus'])->name('booking.updateStatus');

        // Route Approve/Reject Payment
        Route::post('/bookings/{id}/approve-payment', [BookingController::class, 'approvePayment'])->name('booking.approvePayment');
        Route::post('/bookings/{id}/reject-payment', [BookingController::class, 'rejectPayment'])->name('booking.rejectPayment');

        // Logout Admin
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
        
    });

});