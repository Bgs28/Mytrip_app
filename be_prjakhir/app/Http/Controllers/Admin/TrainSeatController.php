<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Train;
use App\Models\TrainSeat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TrainSeatController extends Controller
{
    /**
     * Display a listing of the train seats.
     */
    public function index(Request $request)
    {
        $query = TrainSeat::with('train');

        // Filter by train
        if ($request->has('train_id') && $request->train_id) {
            $query->where('train_id', $request->train_id);
            $train = Train::find($request->train_id);
        } else {
            $train = null;
        }

        // Filter by seat class
        if ($request->has('seat_class') && $request->seat_class) {
            $query->where('seat_class', $request->seat_class);
        }

        // Filter by availability
        if ($request->has('availability') && $request->availability) {
            $query->where('is_available', $request->availability === 'available');
        }

        $seats = $query->paginate(20);
        $trains = Train::all();
        $seatClasses = ['economy', 'business', 'executive'];

        return view('admin.train-seats.index', compact('seats', 'trains', 'train', 'seatClasses'));
    }

    
    /**
     * Display the specified train seat.
     */
    public function show($id)
    {
        $seat = TrainSeat::with('train')->findOrFail($id);
        return view('admin.train-seats.show', compact('seat'));
    }

    
    /**
     * Toggle seat availability
     */
    public function toggleAvailability($id)
    {
        $seat = TrainSeat::findOrFail($id);
        $seat->update(['is_available' => !$seat->is_available]);

        $status = $seat->is_available ? 'tersedia' : 'tidak tersedia';
        return redirect()->back()
            ->with('success', "Kursi berhasil diubah menjadi {$status}!");
    }

    /**
     * Regenerate seats for a train
     */
    public function regenerate(Request $request)
    {
        $request->validate([
            'train_id' => 'required|exists:trains,id'
        ]);

        $train = Train::find($request->train_id);
        
        // Hapus semua kursi existing
        $train->seats()->delete();
        
        // Generate ulang kursi
        $train->generateSeats();

        return redirect()->route('admin.train-seats.index', ['train_id' => $train->id])
            ->with('success', 'Kursi kereta berhasil di-generate ulang!');
    }
}