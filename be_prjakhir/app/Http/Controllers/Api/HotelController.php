<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use Illuminate\Http\Request;

class HotelController extends Controller
{
    // Mengambil semua data hotel (bisa difilter berdasarkan nama atau lokasi)
    public function index(Request $request)
    {
        $query = Hotel::query();

        // Filter berdasarkan nama atau lokasi hotel
        if ($request->has('search') && $request->search != '') {
            $query->where('hotel_name', 'LIKE', '%' . $request->search . '%')
                  ->orWhere('location', 'LIKE', '%' . $request->search . '%');
        }

        $hotels = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar hotel berhasil dimuat',
            'data'    => $hotels
        ], 200);
    }

    // Mengambil detail satu hotel
    public function show($id)
    {
        $hotel = Hotel::find($id);

        if (!$hotel) {
            return response()->json([
                'success' => false,
                'message' => 'Data hotel tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail hotel berhasil ditemukan',
            'data'    => $hotel
        ], 200);
    }
}