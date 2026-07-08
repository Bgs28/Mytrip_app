<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Train;
use Illuminate\Http\Request;

class TrainController extends Controller
{
    // Mengambil semua data kereta (bisa difilter dari Flutter)
    public function index(Request $request)
    {
        $query = Train::query();

        if ($request->has('from') && $request->from != '') {
            $query->where('from', 'LIKE', '%' . $request->from . '%');
        }

        if ($request->has('destination') && $request->destination != '') {
            $query->where('destination', 'LIKE', '%' . $request->destination . '%');
        }

        $trains = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tiket kereta berhasil dimuat',
            'data'    => $trains
        ], 200);
    }

    // Mengambil detail satu kereta
    public function show($id)
    {
        $train = Train::find($id);

        if (!$train) {
            return response()->json([
                'success' => false,
                'message' => 'Data tiket kereta tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail tiket kereta berhasil ditemukan',
            'data'    => $train
        ], 200);
    }
}