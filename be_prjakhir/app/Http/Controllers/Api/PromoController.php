<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use Illuminate\Http\Request;

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

    // Validate promo code
    public function validatePromo(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
            'total_price' => 'required|numeric|min:0'
        ]);

        $promo = Promo::where('code', $request->code)->first();

        if (!$promo) {
            return response()->json([
                'success' => false,
                'message' => 'Kode promo tidak ditemukan'
            ], 404);
        }

        if (!$promo->isValid($request->total_price)) {
            return response()->json([
                'success' => false,
                'message' => 'Kode promo tidak valid atau sudah kadaluarsa'
            ], 400);
        }

        $discount = $promo->calculateDiscount($request->total_price);

        return response()->json([
            'success' => true,
            'message' => 'Kode promo valid',
            'data' => [
                'promo' => $promo,
                'discount_amount' => $discount,
                'final_price' => $request->total_price - $discount
            ]
        ]);
    }
}
