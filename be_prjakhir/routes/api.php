<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BusController;
use App\Http\Controllers\Api\TrainController;
use App\Http\Controllers\Api\HotelController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\ETicketController;
use App\Http\Controllers\Api\HotelRoomController;

/*
|--------------------------------------------------------------------------
| API Routes - Proyek MyTrip
|--------------------------------------------------------------------------
*/

// ==========================================
// 1. AKSES SEBELUM LOGIN (Publik)
// ==========================================
// User hanya bisa melihat daftar list utama & mencari tiket di halaman Home
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login'])->name('login'); 

Route::get('/buses', [BusController::class, 'index']);      // List Bus + Cari
Route::get('/trains', [TrainController::class, 'index']);    // List Kereta + Cari
Route::get('/hotels', [HotelController::class, 'index']);    // List Hotel + Cari

Route::get('/promos', [PromoController::class, 'index']);

// hotel room routes
Route::get('/hotels/{id}/rooms', [HotelRoomController::class, 'getHotelRooms']);
Route::get('/rooms/{id}/availability', [HotelRoomController::class, 'checkAvailability']);


// ==========================================
// 2. AKSES SETELAH LOGIN (Wajib Token Sanctum)
// ==========================================
// Ketika user klik salah satu tiket untuk melihat detail atau masuk ke profil/riwayat,
// Flutter harus mengarahkan ke halaman Login/Register terlebih dahulu.
Route::middleware('auth:sanctum')->group(function () {

    // A. Detail Tiket (Sesuai Alur Baru: Wajib Login untuk melihat harga detail & deskripsi)
    Route::get('/buses/{id}', [BusController::class, 'show']);  
    Route::get('/trains/{id}', [TrainController::class, 'show']);
    Route::get('/hotels/{id}', [HotelController::class, 'show']);

    // B. Halaman Profil User
    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Data profil user berhasil diambil',
            'data'    => $request->user()
        ]);
    });

    // C. Transaksi Booking & Metode Pembayaran
    Route::post('/bookings', [BookingController::class, 'store']);       // Mengirim data pemesanan
    Route::get('/bookings/history', [BookingController::class, 'history']); // Halaman Riwayat Pemesanan
    Route::get('/bookings/{id}', [BookingController::class, 'show']);    // Detail Riwayat Pemesanan
    Route::patch('/bookings/{id}/cancel', [BookingController::class, 'cancel']); // Batalkan Pemesanan
    
     // Promo
    Route::post('/promos/validate', [PromoController::class, 'validatePromo']);
    Route::resource('promos', PromoController::class);
    Route::post('/promos/{id}/toggle-active', [PromoController::class, 'toggleActive'])
        ->name('promos.toggleActive');

    // Payment
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::post('/payments/{id}/upload-proof', [PaymentController::class, 'uploadProof']);
    Route::get('/payments/{id}', [PaymentController::class, 'show']);
    Route::get('/payments/history', [PaymentController::class, 'history']);

    // E-Ticket
    Route::get('/e-tickets/{booking_id}', [ETicketController::class, 'show']);
    Route::post('/e-tickets/check-in', [ETicketController::class, 'checkIn']);

    // Room Booking
    Route::post('/rooms/book', [HotelRoomController::class, 'bookRoom']);
    Route::get('/room-bookings/{id}', [HotelRoomController::class, 'getRoomBookingDetail']);
});