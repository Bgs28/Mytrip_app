<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bus;
use Illuminate\Http\Request;

class BusController extends Controller
{
    // Mengambil semua data bus (bisa difilter dari Flutter)
    public function index(Request $request)
    {
        $query = Bus::query();

        // Filter Kota Asal (jika dicari di Flutter)
        if ($request->has('from') && $request->from != '') {
            $query->where('from', 'LIKE', '%' . $request->from . '%');
        }

        // Filter Kota Tujuan (jika dicari di Flutter)
        if ($request->has('destination') && $request->destination != '') {
            $query->where('destination', 'LIKE', '%' . $request->destination . '%');
        }

        $buses = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tiket bus berhasil dimuat',
            'data'    => $buses
        ], 200);
    }

    // Mengambil detail satu bus berdasarkan ID
    public function show($id)
    {
        $bus = Bus::find($id);

        if (!$bus) {
            return response()->json([
                'success' => false,
                'message' => 'Data tiket bus tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail bus berhasil ditemukan',
            'data'    => $bus
        ], 200);
    }
}