<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    // User membuat booking dari Flutter
    public function store(Request $request)
    {
        $request->validate([
            'type'        => 'required|in:bus,train,hotel',
            'item_id'     => 'required',
            'total_price' => 'required|numeric',
        ]);

        $booking = Booking::create([
            'user_id'      => $request->user()->id, // FIX: Menggunakan property id, bukan method id()
            'type'         => $request->type,
            'item_id'      => $request->item_id,
            'booking_code' => 'MYT-' . strtoupper(Str::random(8)),
            'total_price'  => $request->total_price,
            'status'       => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibuat',
            'data'    => $booking
        ], 201);
    }

    // Riwayat (History) booking milik user yang sedang login
    public function history(Request $request)
    {
        $bookings = Booking::where('user_id', $request->user()->id) // FIX
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Riwayat booking berhasil diambil',
            'data'    => $bookings
        ], 200);
    }

    // Detail satu booking milik user yang sedang login
    public function show(Request $request, $id)
    {
        $booking = Booking::where('user_id', $request->user()->id)->find($id); // FIX

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Data booking tidak ditemukan atau bukan milik Anda'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail booking berhasil diambil',
            'data'    => $booking
        ], 200);
    }

    // Admin melihat semua booking dari panel dashboard web (jika diperlukan via API)
    public function index()
    {
        $bookings = Booking::with('user')->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Semua data booking berhasil diambil',
            'data'    => $bookings
        ], 200);
    }

    //cancel booking
     public function cancel(Request $request, $id)
    {
        $booking = Booking::where('user_id', $request->user()->id)->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        // Cek apakah booking bisa dibatalkan (hanya yang status pending)
        if ($booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Booking dengan status ' . $booking->status . ' tidak dapat dibatalkan'
            ], 400);
        }

        // Update status menjadi cancel
        $booking->update([
            'status' => 'cancel'
        ]);

        // Jika ada payment yang terkait, update juga
        if ($booking->payment) {
            $booking->payment->update([
                'status' => 'refunded'
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibatalkan',
            'data' => $booking
        ], 200);
    }
}