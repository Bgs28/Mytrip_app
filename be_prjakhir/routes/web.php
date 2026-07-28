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
use App\Http\Controllers\Admin\RoomController;
use App\Http\Controllers\Admin\TrainSeatController;
use App\Http\Controllers\Admin\BusSeatController;

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

        // CRUD Kelola Room
        Route::resource('rooms', RoomController::class);
        Route::post('/rooms/{id}/toggle-availability', [RoomController::class, 'toggleAvailability'])
            ->name('rooms.toggleAvailability');

        // CRUD kelola Train
        Route::resource('trains', TrainController::class);
        
        // CRUD kelola Bus
        Route::resource('buses', BusController::class);

        // Route Train Seats
        Route::get('/train-seats', [TrainSeatController::class, 'index'])->name('train-seats.index');
        Route::get('/train-seats/{id}', [TrainSeatController::class, 'show'])->name('train-seats.show');
        Route::post('/train-seats/{id}/toggle-availability', [TrainSeatController::class, 'toggleAvailability'])->name('train-seats.toggleAvailability');
        Route::post('/train-seats/regenerate', [TrainSeatController::class, 'regenerate'])->name('train-seats.regenerate');

        // Route Bus Seats
        Route::get('/bus-seats', [BusSeatController::class, 'index'])->name('bus-seats.index');
        Route::get('/bus-seats/{id}', [BusSeatController::class, 'show'])->name('bus-seats.show');
        Route::post('/bus-seats/{id}/toggle-availability', [BusSeatController::class, 'toggleAvailability'])->name('bus-seats.toggleAvailability');
        Route::post('/bus-seats/regenerate', [BusSeatController::class, 'regenerate'])->name('bus-seats.regenerate');

        // Route Kelola Booking Admin
        Route::get('/bookings', [BookingController::class, 'index'])->name('booking.index');
        Route::get('/bookings/{id}', [BookingController::class, 'show'])->name('booking.show');
        Route::patch('/bookings/{id}/status', [BookingController::class, 'updateStatus'])->name('booking.updateStatus');

        // Route Approve/Reject Payment
        Route::post('/bookings/{id}/approve-payment', [BookingController::class, 'approvePayment'])->name('booking.approvePayment');
        Route::post('/bookings/{id}/reject-payment', [BookingController::class, 'rejectPayment'])->name('booking.rejectPayment');

        // Logout Admin
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

        // Laporan
        Route::get('/reports', [\App\Http\Controllers\Admin\ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/bookings', [\App\Http\Controllers\Admin\ReportController::class, 'bookings'])->name('reports.bookings');
        Route::get('/reports/revenue', [\App\Http\Controllers\Admin\ReportController::class, 'revenue'])->name('reports.revenue');
        Route::get('/reports/monthly', [\App\Http\Controllers\Admin\ReportController::class, 'monthly'])->name('reports.monthly');
        
    });

});