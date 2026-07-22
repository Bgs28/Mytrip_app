<?php

namespace App\Http\Controllers\Admin;


use App\Models\ETicket;
use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;

class BookingController extends Controller
{
    // Menampilkan halaman daftar semua booking dari user
    public function index()
    {
        // Mengambil data booking beserta relasi user dan payment
        $bookings = Booking::with(['user', 'payment'])
            ->latest()
            ->paginate(10);
        
        return view('admin.booking.index', compact('bookings'));
    }

    // Menampilkan detail booking untuk admin
    public function show($id)
    {
        $booking = Booking::with(['user', 'payment', 'payment.promo'])
            ->findOrFail($id);
        
        return view('admin.booking.show', compact('booking'));
    }

    // Mengubah/memperbarui status transaksi booking
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,paid,cancel',
        ]);

        $booking = Booking::findOrFail($id);
        
        $booking->update([
            'status' => $request->status
        ]);

        // Jika status diubah ke paid, update payment juga
        if ($request->status == 'paid' && $booking->payment) {
            $booking->payment->update([
                'status' => 'paid',
                'paid_at' => now()
            ]);
        }

        // Jika status diubah ke cancel, update payment juga
        if ($request->status == 'cancel' && $booking->payment) {
            $booking->payment->update([
                'status' => 'refunded'
            ]);
        }

        Log::info('Admin updated booking status', [
            'booking_id' => $booking->id,
            'status' => $request->status,
            'admin_id' => Auth::id()
        ]);

        return redirect()->route('admin.booking.index')
            ->with('success', 'Status booking berhasil diperbarui!');
    }

    // Approve payment dari admin
    // app/Http/Controllers/Admin/BookingController.php

public function approvePayment(Request $request, $id)
{
    $booking = Booking::with('payment')->findOrFail($id);

    if (!$booking->payment) {
        return redirect()->back()->with('error', 'Booking ini belum memiliki pembayaran.');
    }

    if ($booking->payment->status == 'paid') {
        return redirect()->back()->with('error', 'Pembayaran sudah di-approve sebelumnya.');
    }

    if (!$booking->payment->proof_of_payment) {
        return redirect()->back()->with('error', 'Belum ada bukti pembayaran yang diunggah.');
    }

    // Update payment status
    $booking->payment->update([
        'status' => 'paid',
        'paid_at' => now()
    ]);

    // Update booking status
    $booking->update([
        'status' => 'paid'
    ]);

    // GENERATE E-TICKET
    $eTicket = $this->generateETicket($booking);

    Log::info('Admin approved payment and generated e-ticket', [
        'booking_id' => $booking->id,
        'payment_id' => $booking->payment->id,
        'e_ticket_id' => $eTicket->id ?? null,
        'admin_id' => Auth::id()
    ]);

    return redirect()->route('admin.booking.show', $booking->id)
        ->with('success', 'Pembayaran berhasil di-approve! E-Ticket telah dibuat.');
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

    // Reject payment dari admin
    public function rejectPayment(Request $request, $id)
    {
        $booking = Booking::with('payment')->findOrFail($id);

        if (!$booking->payment) {
            return redirect()->back()->with('error', 'Booking ini belum memiliki pembayaran.');
        }

        if ($booking->payment->status == 'paid') {
            return redirect()->back()->with('error', 'Pembayaran sudah di-approve sebelumnya.');
        }

        // Update payment status menjadi failed
        $booking->payment->update([
            'status' => 'failed'
        ]);

        // Booking status tetap pending atau bisa diubah ke cancel
        // $booking->update([
        //     'status' => 'cancel'
        // ]);

        Log::info('Admin rejected payment', [
            'booking_id' => $booking->id,
            'payment_id' => $booking->payment->id,
            'admin_id' => Auth::id()
        ]);

        return redirect()->route('admin.booking.show', $booking->id)
            ->with('error', 'Pembayaran ditolak. Silahkan hubungi user untuk upload ulang.');
    }
}