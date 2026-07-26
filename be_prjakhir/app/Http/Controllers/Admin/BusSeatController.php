<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bus;
use App\Models\BusSeat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BusSeatController extends Controller
{
    /**
     * Display a listing of the bus seats.
     */
    public function index(Request $request)
    {
        $query = BusSeat::with('bus');

        // Filter by bus
        if ($request->has('bus_id') && $request->bus_id) {
            $query->where('bus_id', $request->bus_id);
            $bus = Bus::find($request->bus_id);
        } else {
            $bus = null;
        }

        // Filter by seat type
        if ($request->has('seat_type') && $request->seat_type) {
            $query->where('seat_type', $request->seat_type);
        }

        // Filter by availability
        if ($request->has('availability') && $request->availability) {
            $query->where('is_available', $request->availability === 'available');
        }

        $seats = $query->paginate(20);
        $buses = Bus::all();
        $seatTypes = ['regular', 'premium', 'executive'];

        return view('admin.bus-seats.index', compact('seats', 'buses', 'bus', 'seatTypes'));
    }

    /**
     * Display the specified bus seat.
     */
    public function show($id)
    {
        $seat = BusSeat::with('bus')->findOrFail($id);
        return view('admin.bus-seats.show', compact('seat'));
    }


    /**
     * Toggle seat availability
     */
    public function toggleAvailability($id)
    {
        $seat = BusSeat::findOrFail($id);
        $seat->update(['is_available' => !$seat->is_available]);

        $status = $seat->is_available ? 'tersedia' : 'tidak tersedia';
        return redirect()->back()
            ->with('success', "Kursi berhasil diubah menjadi {$status}!");
    }

    /**
     * Regenerate seats for a bus
     */
    public function regenerate(Request $request)
    {
        $request->validate([
            'bus_id' => 'required|exists:buses,id'
        ]);

        $bus = Bus::find($request->bus_id);
        
        // Hapus semua kursi existing
        $bus->seats()->delete();
        
        // Generate ulang kursi
        $bus->generateSeats();

        return redirect()->route('admin.bus-seats.index', ['bus_id' => $bus->id])
            ->with('success', 'Kursi bus berhasil di-generate ulang!');
    }
}