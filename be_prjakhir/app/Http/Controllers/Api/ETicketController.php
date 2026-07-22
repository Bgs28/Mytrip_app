<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ETicket;
use App\Models\Booking;
use Illuminate\Http\Request;

class ETicketController extends Controller
{
    // Get E-Ticket by booking ID
    public function show(Request $request, $bookingId)
    {
        $eTicket = ETicket::where('booking_id', $bookingId)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$eTicket) {
            return response()->json([
                'success' => false,
                'message' => 'E-Ticket tidak ditemukan'
            ], 404);
        }

        // Get booking detail
        $booking = Booking::with(['user'])->find($bookingId);

        return response()->json([
            'success' => true,
            'message' => 'E-Ticket berhasil diambil',
            'data' => [
                'e_ticket' => $eTicket,
                'booking' => $booking,
                'qr_code' => $eTicket->qr_code // base64 image
            ]
        ]);
    }

    // Check-in using check-in code
    public function checkIn(Request $request)
    {
        $request->validate([
            'check_in_code' => 'required|string|size:6'
        ]);

        $eTicket = ETicket::where('check_in_code', $request->check_in_code)
            ->where('is_used', false)
            ->first();

        if (!$eTicket) {
            return response()->json([
                'success' => false,
                'message' => 'Kode check-in tidak valid atau sudah digunakan'
            ], 404);
        }

        // Update status
        $eTicket->update([
            'is_used' => true,
            'used_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Check-in berhasil! Selamat menikmati perjalanan.',
            'data' => $eTicket
        ]);
    }
}