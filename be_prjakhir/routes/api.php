<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Untuk lihat semua user
Route::get('/users', [UserController::class, 'index']);

// Untuk tambah user
Route::post('/users', [UserController::class, 'store']);

// Untuk hapus user
Route::delete('/users/{id}', [UserController::class, 'destroy']);

// Update pakai PUT atau PATCH
Route::put('/users/{id}', [UserController::class, 'update']);

// Hapus pakai DELETE
Route::delete('/users/{id}', [UserController::class, 'destroy']);

// login
Route::post('/login', [UserController::class, 'login']);

