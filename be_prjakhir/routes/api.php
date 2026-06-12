<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\FlightController;
use App\Http\Controllers\Api\HotelController;
use App\Http\Controllers\Api\TrainController;
use App\Http\Controllers\Api\BusController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\AuthController;

use App\Http\Controllers\UserController;
use App\Models\Booking;

// AUTH
Route::post('/register',[AuthController::class,'register']);
Route::post('/login', [AuthController::class, 'login']);

// DATA TRAVEL

Route::get('/flights',
[
    FlightController::class,
    'index'
]);


Route::get('/hotels',
[
    HotelController::class,
    'index'
]);


Route::get('/trains',
[
    TrainController::class,
    'index'
]);


Route::get('/buses',
[
    BusController::class,
    'index'
]);


// USER PROFILE (butuh token)

Route::middleware('auth:sanctum')
->group(function(){


    Route::get('/user', function(
        Request $request
    ){
        return $request->user();
    });


});

Route::middleware('auth:sanctum')
->group(function(){

    // buat booking
    Route::post(
        '/bookings',
        [
            BookingController::class,
            'store'
        ]
    );

    // history user
    Route::get(
        '/history',
        [
            BookingController::class,
            'history'
        ]
    );

    // detail booking
    Route::get(
        '/booking/{id}',
        [
            BookingController::class,
            'show'
        ]
    );
});