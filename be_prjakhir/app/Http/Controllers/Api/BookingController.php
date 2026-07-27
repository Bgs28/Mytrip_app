<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;


class BookingController extends Controller
{
    // User membuat booking dari Flutter
    public function store(Request $request)
    {
        try {
            Log::info('Booking store request', $request->all());

            $validator = Validator::make($request->all(), [
                'type' => 'required|in:bus,train,hotel',
                'item_id' => 'required|integer',
                'total_price' => 'required|numeric|min:0',
                'notes' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Cek apakah booking sudah ada untuk item ini (untuk mencegah double booking)
            // TODO: Tambahkan validasi sesuai jenis (bus/train/hotel)

            $booking = Booking::create([
                'user_id' => $request->user()->id,
                'type' => $request->type,
                'item_id' => $request->item_id,
                'booking_code' => 'MYT-' . strtoupper(Str::random(8)),
                'total_price' => $request->total_price,
                'status' => 'pending',
                'notes' => $request->notes
            ]);

            Log::info('Booking created', ['booking_id' => $booking->id]);

            return response()->json([
                'success' => true,
                'message' => 'Booking berhasil dibuat. Silahkan lanjutkan ke pembayaran.',
                'data' => $booking
            ], 201);

        } catch (\Exception $e) {
            Log::error('Booking creation error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
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