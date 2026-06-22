<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Admin\HotelController;

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

        // CRUD Kelola Hotel
        Route::resource('hotels', HotelController::class);
        
        // Logout Admin
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
        
    });

});