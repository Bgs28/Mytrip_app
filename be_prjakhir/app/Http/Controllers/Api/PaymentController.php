<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Booking;
use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    /**
     * Create payment for booking
     */
    public function store(Request $request)
    {
        try {
            Log::info('Payment store request', $request->all());

            $validator = Validator::make($request->all(), [
                'booking_id' => 'required|exists:bookings,id',
                'payment_method' => 'required|in:bank_transfer_bca,bank_transfer_mandiri,bank_transfer_bni,ovo,gopay',
                'promo_code' => 'nullable|string|exists:promos,code',
                'notes' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $booking = Booking::with('user')->find($request->booking_id);

            // Cek apakah booking milik user
            if ($booking->user_id != $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }

            // Cek apakah payment sudah ada
            $existingPayment = Payment::where('booking_id', $booking->id)->first();
            if ($existingPayment) {
                return response()->json([
                    'success' => true,
                    'message' => 'Pembayaran sudah ada',
                    'data' => $existingPayment
                ]);
            }

            $baseAmount = $booking->total_price;
            $discountAmount = 0;
            $promoId = null;

            // Apply promo jika ada
            if ($request->has('promo_code')) {
                $promo = Promo::where('code', $request->promo_code)->first();
                if ($promo && $promo->isValid($baseAmount)) {
                    $discountAmount = $promo->calculateDiscount($baseAmount);
                    $promoId = $promo->id;
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

            // Update booking dengan promo
            $booking->update([
                'promo_id' => $promoId,
                'discount_amount' => $discountAmount
            ]);

            Log::info('Payment created', ['payment_id' => $payment->id, 'booking_id' => $booking->id]);

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil dibuat. Silahkan upload bukti pembayaran.',
                'data' => $payment
            ]);

        } catch (\Exception $e) {
            Log::error('Payment creation error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Upload proof of payment
     */
    public function uploadProof(Request $request, $id)
    {
        try {
            Log::info('Upload proof request', ['payment_id' => $id]);

            $validator = Validator::make($request->all(), [
                'proof_of_payment' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $payment = Payment::with('booking')->find($id);

            if (!$payment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pembayaran tidak ditemukan'
                ], 404);
            }

            if ($payment->user_id != $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            if ($payment->status == 'paid') {
                return response()->json([
                    'success' => false,
                    'message' => 'Pembayaran sudah dikonfirmasi'
                ], 400);
            }

            // Upload file
            if ($request->hasFile('proof_of_payment')) {
                $file = $request->file('proof_of_payment');
                $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
                $path = $file->storeAs('payments', $filename, 'public');

                // Update payment dengan bukti (status tetap pending)
                $payment->update([
                    'proof_of_payment' => $filename,
                    'status' => 'pending' // tetap pending sampai di-approve admin
                ]);

                Log::info('Proof uploaded', ['payment_id' => $payment->id, 'filename' => $filename]);

                return response()->json([
                    'success' => true,
                    'message' => 'Bukti pembayaran berhasil diupload. Menunggu verifikasi admin.',
                    'data' => $payment
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'File tidak ditemukan'
            ], 400);

        } catch (\Exception $e) {
            Log::error('Upload proof error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payment detail
     */
    public function show(Request $request, $id)
    {
        try {
            $payment = Payment::with(['booking', 'promo'])
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

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payment history for user - FIX
     */
    public function history(Request $request)
    {
        try {
            Log::info('Payment history request', ['user_id' => $request->user()->id]);

            // Ambil semua payment user
            $payments = Payment::with(['booking', 'promo'])
                ->where('user_id', $request->user()->id)
                ->orderBy('created_at', 'desc')
                ->get();

            // Jika tidak ada data, return empty array (bukan 404)
            return response()->json([
                'success' => true,
                'message' => 'Riwayat pembayaran berhasil diambil',
                'data' => $payments
            ], 200);

        } catch (\Exception $e) {
            Log::error('Payment history error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payment by booking ID
     */
    public function getByBooking(Request $request, $bookingId)
    {
        try {
            $payment = Payment::with(['booking', 'promo'])
                ->where('user_id', $request->user()->id)
                ->where('booking_id', $bookingId)
                ->first();

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

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}