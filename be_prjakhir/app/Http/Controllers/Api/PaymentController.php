<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Booking;
use App\Models\Promo;
use App\Models\ETicket;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\RoundBlockSizeMode;
use Endroid\QrCode\Builder\Builder;

class PaymentController extends Controller
{
    // Create payment from booking - PASTIKAN INI BEKERJA
    public function store(Request $request)
    {
        try {
            Log::info('Payment store called', $request->all());
            
            $request->validate([
                'booking_id' => 'required|exists:bookings,id',
                'payment_method' => 'required|in:bank_transfer_bca,bank_transfer_mandiri,bank_transfer_bni,ovo,gopay',
            ]);

            $booking = Booking::with('user')->find($request->booking_id);

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan'
                ], 404);
            }

            // Check if booking belongs to user
            if ($booking->user_id != $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Check if payment already exists
            $existingPayment = Payment::where('booking_id', $booking->id)->first();
            if ($existingPayment) {
                return response()->json([
                    'success' => true,
                    'message' => 'Pembayaran sudah ada',
                    'data' => $existingPayment
                ], 200);
            }

            $baseAmount = $booking->total_price;
            $discountAmount = 0;
            $promoId = null;

            // Apply promo if exists
            if ($request->has('promo_code') && $request->promo_code) {
                $promo = Promo::where('code', $request->promo_code)->first();
                if ($promo && $promo->isValid($baseAmount)) {
                    $discountAmount = $promo->calculateDiscount($baseAmount);
                    $promoId = $promo->id;
                    $promo->increment('usage_count');
                }

                Log::info('Promo applied', [
                        'promo_id' => $promoId,
                        'discount_amount' => $discountAmount
                    ]);
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

            Log::info('Payment created successfully', ['payment_id' => $payment->id]);

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil dibuat',
                'data' => $payment->load('booking')
            ], 201);

        } catch (\Exception $e) {
            Log::error('Payment creation error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // Upload proof of payment - FIX
    public function uploadProof(Request $request, $id)
    {
        try {
            Log::info('Upload proof called for payment ID: ' . $id);
            
            $request->validate([
                'proof_of_payment' => 'required|image|max:2048'
            ]);

            // Cari payment dengan relasi booking
            $payment = Payment::with('booking')->find($id);

            if (!$payment) {
                Log::error('Payment not found: ' . $id);
                return response()->json([
                    'success' => false,
                    'message' => 'Pembayaran tidak ditemukan'
                ], 404);
            }

            // Check if payment belongs to user
            if ($payment->user_id != $request->user()->id) {
                Log::error('Unauthorized: user ' . $request->user()->id . ' trying to access payment ' . $id);
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            // Check if payment already paid
            if ($payment->status == 'paid') {
                return response()->json([
                    'success' => false,
                    'message' => 'Pembayaran sudah dikonfirmasi'
                ], 400);
            }

            // Upload file
            if ($request->hasFile('proof_of_payment')) {
                $file = $request->file('proof_of_payment');
                
                // Validasi file
                if (!$file->isValid()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'File tidak valid'
                    ], 400);
                }

                $filename = time() . '_' . $file->getClientOriginalName();
                $path = $file->storeAs('payment_proofs', $filename, 'public');
                
                Log::info('File uploaded to: ' . $path);
                
                // UPDATE: Status tetap pending, hanya simpan bukti pembayaran
                $payment->update([
                    'proof_of_payment' => $path,
                    // 'status' => 'paid',
                    // 'paid_at' => now()
                ]);

                // Update booking status - untuk sekarang tetap pending dahulu
                // if ($payment->booking) {
                //     $payment->booking->update(['status' => 'paid']);
                // }

                return response()->json([
                    'success' => true,
                    'message' => 'Bukti pembayaran berhasil diunggah',
                    'data' => $payment->fresh(['booking'])
                ], 200);
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

    // Get payment detail
    public function show(Request $request, $id)
    {
        try {
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
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get payment history
    public function history(Request $request)
    {
        try {
            $payments = Payment::with(['booking', 'promo'])
                ->where('user_id', $request->user()->id)
                ->latest()
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Riwayat pembayaran berhasil diambil',
                'data' => $payments
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    
    // Tambahkan method untuk admin approve payment
    public function approvePayment(Request $request, $id)
    {
    try {
        // Cek apakah user adalah admin
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Hanya admin yang dapat mengakses.'
            ], 403);
        }

        $payment = Payment::with('booking')->find($id);

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        if (!$payment->proof_of_payment) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada bukti pembayaran yang diunggah'
            ], 400);
        }

        if ($payment->status == 'paid') {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran sudah di-approve sebelumnya'
            ], 400);
        }

        // Approve payment
        $payment->update([
            'status' => 'paid',
            'paid_at' => now()
        ]);

        // Update booking status
        if ($payment->booking) {
            $payment->booking->update([
                'status' => 'paid'
            ]);

            // GENERATE E-TICKET
            $eTicket = $this->generateETicket($payment->booking);
        }

        Log::info('Payment approved by admin', [
            'payment_id' => $payment->id,
            'booking_id' => $payment->booking_id,
            'e_ticket_id' => $eTicket->id ?? null
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil di-approve',
            'data' => [
                'payment' => $payment->fresh(['booking']),
                'e_ticket' => $eTicket ?? null
            ]
        ], 200);

    } catch (\Exception $e) {
        Log::error('Approve payment error: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
    }

    // Tambahkan method untuk admin melihat semua payment
    public function adminIndex(Request $request)
    {
        try {
            // Cek apakah user adalah admin
            if ($request->user()->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Hanya admin yang dapat mengakses.'
                ], 403);
            }

            $payments = Payment::with(['booking', 'user', 'promo'])
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Data pembayaran berhasil diambil',
                'data' => $payments
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // Tambahkan method untuk admin melihat detail payment
    public function adminShow(Request $request, $id)
    {
        try {
            // Cek apakah user adalah admin
            if ($request->user()->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Hanya admin yang dapat mengakses.'
                ], 403);
            }

            $payment = Payment::with(['booking', 'booking.user', 'promo', 'user'])
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
                ], 200);
                } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // Generate E-Ticket
private function generateETicket($booking)
    {
        // Cek apakah sudah ada e-ticket
        $existingTicket = ETicket::where('booking_id', $booking->id)->first();
        if ($existingTicket) {
            return $existingTicket;
        }

        // Generate ticket code
        $ticketCode = ETicket::generateTicketCode();
        $checkInCode = ETicket::generateCheckInCode();

        // Data untuk QR Code
        $qrData = json_encode([
            'ticket_code' => $ticketCode,
            'booking_code' => $booking->booking_code,
            'check_in_code' => $checkInCode,
            'type' => $booking->type,
            'item_id' => $booking->item_id,
            'user_id' => $booking->user_id,
            'valid_until' => now()->addDays(30)->toIso8601String()
        ]);

        // Generate QR Code menggunakan endroid/qr-code
        $qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' . urlencode($qrData);
    
    // Download QR Code image
    $qrCodeImage = file_get_contents($qrCodeUrl);
    $qrCodeBase64 = base64_encode($qrCodeImage);

    // Create E-Ticket
    $eTicket = ETicket::create([
        'booking_id' => $booking->id,
        'user_id' => $booking->user_id,
        'ticket_code' => $ticketCode,
        'qr_code' => $qrCodeBase64,
        'valid_from' => now(),
        'valid_until' => now()->addDays(30),
        'is_used' => false,
        'check_in_code' => $checkInCode
    ]);

    return $eTicket;
    }
}