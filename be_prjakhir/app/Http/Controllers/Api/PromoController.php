<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PromoController extends Controller
{
    // Get all active promos
    public function index(Request $request)
    {
        $query = Promo::where('is_active', true)
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now());

        // Filter by target type
        if ($request->has('target_type') && $request->target_type != 'all') {
            $query->where('target_type', $request->target_type);
        }

        $promos = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar promo berhasil dimuat',
            'data' => $promos
        ]);
    }

    // Validate promo code - FIX
    public function validatePromo(Request $request)
    {
         try {
        $request->validate([
            'code' => 'required|string',
            'total_price' => 'required|numeric|min:0'
        ]);

        // Gunakan timezone Asia/Jakarta
        $now = now('Asia/Jakarta');
        
        Log::info('Validating promo code: ' . $request->code);
        Log::info('Current time: ' . $now->toDateTimeString());

        // Cari promo dengan code (case insensitive)
        $promo = Promo::whereRaw('UPPER(code) = UPPER(?)', [$request->code])->first();

        if (!$promo) {
            Log::warning('Promo code not found: ' . $request->code);
            return response()->json([
                'success' => false,
                'message' => 'Kode promo tidak ditemukan'
            ], 404);
        }

        Log::info('Promo found:', [
            'id' => $promo->id,
            'code' => $promo->code,
            'is_active' => $promo->is_active,
            'start_date' => $promo->start_date,
            'end_date' => $promo->end_date,
            'start_date_utc' => $promo->start_date->toDateTimeString(),
            'end_date_utc' => $promo->end_date->toDateTimeString(),
            'now' => $now->toDateTimeString()
        ]);

        // Cek status aktif
        if (!$promo->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Kode promo tidak aktif'
            ], 400);
        }

        // Cek tanggal mulai (compare di UTC)
        if ($promo->start_date > $now) {
            $diff = $promo->start_date->diffInMinutes($now);
            Log::info('Promo not started yet. Difference: ' . $diff . ' minutes');
            return response()->json([
                'success' => false,
                'message' => 'Promo belum dimulai. Mulai pada: ' . $promo->start_date->format('d M Y H:i')
            ], 400);
        }

        // Cek tanggal berakhir
        if ($promo->end_date < $now) {
            return response()->json([
                'success' => false,
                'message' => 'Promo sudah kadaluarsa'
            ], 400);
        }

        // Cek limit penggunaan
        if ($promo->usage_limit && $promo->usage_count >= $promo->usage_limit) {
            return response()->json([
                'success' => false,
                'message' => 'Kuota promo sudah habis'
            ], 400);
        }

        // Cek minimal pembelian
        if ($request->total_price < $promo->min_purchase) {
            return response()->json([
                'success' => false,
                'message' => 'Minimal pembelian Rp ' . number_format($promo->min_purchase, 0, ',', '.')
            ], 400);
        }

        $discount = $promo->calculateDiscount($request->total_price);
        $finalPrice = $request->total_price - $discount;

        Log::info('Promo valid:', [
            'discount' => $discount,
            'final_price' => $finalPrice
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kode promo valid',
            'data' => [
                'promo' => $promo,
                'discount_amount' => $discount,
                'final_price' => $finalPrice
            ]
        ]);

    } catch (\Exception $e) {
        Log::error('Validate promo error: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
    }
}