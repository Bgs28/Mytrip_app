<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Booking;
use App\Models\Promo;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    // Create payment from booking
    public function store(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'payment_method' => 'required|in:bank_transfer_bca,bank_transfer_mandiri,bank_transfer_bni,ovo,gopay',
            'promo_code' => 'nullable|string|exists:promos,code'
        ]);

        $booking = Booking::with('user')->find($request->booking_id);

        // Check if booking belongs to user
        if ($booking->user_id != $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }

        // Check if payment already exists
        $existingPayment = Payment::where('booking_id', $booking->id)->first();
        if ($existingPayment) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran untuk booking ini sudah dibuat'
            ], 400);
        }

        $baseAmount = $booking->total_price;
        $discountAmount = 0;
        $promoId = null;

        // Apply promo if exists
        if ($request->has('promo_code')) {
            $promo = Promo::where('code', $request->promo_code)->first();
            if ($promo && $promo->isValid($baseAmount)) {
                $discountAmount = $promo->calculateDiscount($baseAmount);
                $promoId = $promo->id;
                
                // Increment usage count
                $promo->increment('usage_count');
            }
        }

        $totalAmount = $baseAmount - $discountAmount;

        // Create payment
        $payment = Payment::create([
            'booking_id' => $booking->id,
            'user_id' => $request->user()->id,
            'promo_id' => $promoId,
            'invoice_number' => Payment::generateInvoiceNumber(),
            'base_amount' => $baseAmount,
            'discount_amount' => $discountAmount,
            'total_amount' => $totalAmount,
            'payment_method' => $request->payment_method,
            'status' => 'pending',
            'notes' => $request->notes
        ]);

        // Update booking with promo info
        $booking->update([
            'promo_id' => $promoId,
            'discount_amount' => $discountAmount
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dibuat',
            'data' => $payment
        ], 201);
    }

    // Upload proof of payment
    public function uploadProof(Request $request, $id)
    {
        $request->validate([
            'proof_of_payment' => 'required|image|max:2048'
        ]);

        $payment = Payment::find($id);

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        // Check if payment belongs to user
        if ($payment->user_id != $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        // Upload file
        if ($request->hasFile('proof_of_payment')) {
            $file = $request->file('proof_of_payment');
            $filename = time() . '_' . $file->getClientOriginalName();
            $path = $file->storeAs('payment_proofs', $filename, 'public');
            
            $payment->update([
                'proof_of_payment' => $path,
                'status' => 'paid',
                'paid_at' => now()
            ]);

            // Update booking status
            $payment->booking->update(['status' => 'paid']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Bukti pembayaran berhasil diunggah',
            'data' => $payment
        ]);
    }

    // Get payment detail
    public function show(Request $request, $id)
    {
        $payment = Payment::with(['booking', 'promo', 'user'])
            ->where('user_id', $request->user()->id)
            ->find($id);

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail pembayaran berhasil diambil',
            'data' => $payment
        ]);
    }

    // Get payment history
    public function history(Request $request)
    {
        $payments = Payment::with(['booking', 'promo'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Riwayat pembayaran berhasil diambil',
            'data' => $payments
        ]);
    }
}