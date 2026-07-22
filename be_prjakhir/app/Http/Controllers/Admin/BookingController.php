<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    // Menampilkan halaman daftar semua booking dari user
    public function index()
    {
        // Mengambil data booking beserta relasi user-nya
        $bookings = Booking::with('user')->latest()->paginate(10);
        
        return view('admin.booking.index', compact('bookings'));
    }

    // Mengubah/memperbarui status transaksi booking
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,paid,cancel',
        ]);

        $booking = Booking::findOrFail($id);
        
        // Update status booking
        $booking->update([
            'status' => $request->status
        ]);

        // Redirect dengan pesan sukses
        return redirect()->route('admin.booking.index')->with('success', 'Status booking berhasil diperbarui!');
    }
}