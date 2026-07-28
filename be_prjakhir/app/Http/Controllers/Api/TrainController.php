<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Train;
use App\Models\TrainSchedule;
use App\Models\TrainSeat;
use App\Models\Booking;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class TrainController extends Controller
{
    // Mengambil semua data kereta (bisa difilter dari Flutter)
    public function index(Request $request)
    {
        $query = Train::query();

        if ($request->has('from') && $request->from != '') {
            $query->where('from', 'LIKE', '%' . $request->from . '%');
        }

        if ($request->has('destination') && $request->destination != '') {
            $query->where('destination', 'LIKE', '%' . $request->destination . '%');
        }

        $trains = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tiket kereta berhasil dimuat',
            'data'    => $trains
        ], 200);
    }

    // Mengambil detail satu kereta
    public function show($id)
    {
        $train = Train::find($id);

        if (!$train) {
            return response()->json([
                'success' => false,
                'message' => 'Data tiket kereta tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail tiket kereta berhasil ditemukan',
            'data'    => $train
        ], 200);
    }

    /**
     * Get train schedules
     */
    public function getSchedules(Request $request, $id)
    {
        try {
            $train = Train::find($id);
            
            if (!$train) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kereta tidak ditemukan'
                ], 404);
            }

            // Get schedules for this train
            $schedules = TrainSchedule::where('train_id', $id)
                ->where('departure_date', '>=', now()->toDateString())
                ->orderBy('departure_date')
                ->orderBy('departure_time')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Jadwal kereta berhasil dimuat',
                'data' => $schedules
            ]);

        } catch (\Exception $e) {
            Log::error('Get train schedules error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get train seats with availability for a schedule
     */
    public function getSeats(Request $request, $id)
    {
        try {
            $train = Train::find($id);
            
            if (!$train) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kereta tidak ditemukan'
                ], 404);
            }

            $request->validate([
                'schedule_id' => 'required|exists:train_schedules,id'
            ]);

            $schedule = TrainSchedule::find($request->schedule_id);
            
            // Get all seats for this train
            $seats = TrainSeat::where('train_id', $id)->get();
            
            // Check which seats are booked for this schedule
            $bookedSeats = \App\Models\TrainBookingSeat::where('train_schedule_id', $request->schedule_id)
                ->where('status', '!=', 'cancelled')
                ->pluck('train_seat_id')
                ->toArray();

            // Map seat data with availability
            $seatData = $seats->map(function($seat) use ($bookedSeats) {
                return [
                    'id' => $seat->id,
                    'seat_code' => $seat->seat_code,
                    'seat_number' => $seat->seat_number,
                    'position' => $seat->position,
                    'is_available' => !in_array($seat->id, $bookedSeats) && $seat->is_available,
                ];
            });

            return response()->json([
                'success' => true,
                'message' => 'Kursi kereta berhasil dimuat',
                'data' => $seatData
            ]);

        } catch (\Exception $e) {
            Log::error('Get train seats error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Book train seats
     */
    public function bookSeats(Request $request, $id)
    {
        try {
            $train = Train::find($id);
            
            if (!$train) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kereta tidak ditemukan'
                ], 404);
            }

            $validator = Validator::make($request->all(), [
                'schedule_id' => 'required|exists:train_schedules,id',
                'seat_ids' => 'required|array|min:1',
                'seat_ids.*' => 'exists:train_seats,id',
                'notes' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $schedule = TrainSchedule::find($request->schedule_id);
            
            // Check if seats are available
            $bookedSeats = \App\Models\TrainBookingSeat::where('train_schedule_id', $request->schedule_id)
                ->whereIn('train_seat_id', $request->seat_ids)
                ->where('status', '!=', 'cancelled')
                ->pluck('train_seat_id')
                ->toArray();

            if (!empty($bookedSeats)) {
                $bookedCodes = TrainSeat::whereIn('id', $bookedSeats)->pluck('seat_code')->toArray();
                return response()->json([
                    'success' => false,
                    'message' => 'Kursi sudah dipesan: ' . implode(', ', $bookedCodes)
                ], 400);
            }

            // Calculate total price
            $totalPrice = $schedule->price * count($request->seat_ids);

            // Create booking
            $booking = Booking::create([
                'user_id' => $request->user()->id,
                'type' => 'train',
                'item_id' => $id,
                'booking_code' => 'MYT-' . strtoupper(\Illuminate\Support\Str::random(8)),
                'total_price' => $totalPrice,
                'status' => 'pending',
                'notes' => $request->notes
            ]);

            // Create booking seats
            foreach ($request->seat_ids as $seatId) {
                $seat = TrainSeat::find($seatId);
                \App\Models\TrainBookingSeat::create([
                    'booking_id' => $booking->id,
                    'train_seat_id' => $seatId,
                    'train_schedule_id' => $request->schedule_id,
                    'seat_code' => $seat->seat_code,
                    'price' => $schedule->price,
                    'status' => 'pending'
                ]);
            }

            // Update available seats count
            $schedule->decrement('available_seats', count($request->seat_ids));

            return response()->json([
                'success' => true,
                'message' => 'Booking berhasil dibuat',
                'data' => [
                    'booking' => $booking,
                    'total_price' => $totalPrice,
                    'seats' => count($request->seat_ids)
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Book train seats error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}