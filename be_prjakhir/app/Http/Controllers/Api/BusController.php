<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bus;
use App\Models\BusSchedule;
use App\Models\BusSeat;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class BusController extends Controller
{
    // Mengambil semua data bus (bisa difilter dari Flutter)
    public function index(Request $request)
    {
        $query = Bus::query();

        // Filter Kota Asal (jika dicari di Flutter)
        if ($request->has('from') && $request->from != '') {
            $query->where('from', 'LIKE', '%' . $request->from . '%');
        }

        // Filter Kota Tujuan (jika dicari di Flutter)
        if ($request->has('destination') && $request->destination != '') {
            $query->where('destination', 'LIKE', '%' . $request->destination . '%');
        }

        $buses = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tiket bus berhasil dimuat',
            'data'    => $buses
        ], 200);
    }

    // Mengambil detail satu bus berdasarkan ID
    public function show($id)
    {
        $bus = Bus::find($id);

        if (!$bus) {
            return response()->json([
                'success' => false,
                'message' => 'Data tiket bus tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail bus berhasil ditemukan',
            'data'    => $bus
        ], 200);
    }

    /**
     * Get bus schedules
     */
    public function getSchedules(Request $request, $id)
    {
        try {
            $bus = Bus::find($id);
            
            if (!$bus) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bus tidak ditemukan'
                ], 404);
            }

            // Get schedules for this bus
            $schedules = BusSchedule::where('bus_id', $id)
                ->where('departure_date', '>=', now()->toDateString())
                ->orderBy('departure_date')
                ->orderBy('departure_time')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Jadwal bus berhasil dimuat',
                'data' => $schedules
            ]);

        } catch (\Exception $e) {
            Log::error('Get bus schedules error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get bus seats with availability for a schedule
     */
    public function getSeats(Request $request, $id)
    {
        try {
            $bus = Bus::find($id);
            
            if (!$bus) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bus tidak ditemukan'
                ], 404);
            }

            $request->validate([
                'schedule_id' => 'required|exists:bus_schedules,id'
            ]);

            $schedule = BusSchedule::find($request->schedule_id);
            
            // Get all seats for this bus
            $seats = BusSeat::where('bus_id', $id)->get();
            
            // Check which seats are booked for this schedule
            $bookedSeats = \App\Models\BusBookingSeat::where('bus_schedule_id', $request->schedule_id)
                ->where('status', '!=', 'cancelled')
                ->pluck('bus_seat_id')
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
                'message' => 'Kursi bus berhasil dimuat',
                'data' => $seatData
            ]);

        } catch (\Exception $e) {
            Log::error('Get bus seats error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Book bus seats
     */
    public function bookSeats(Request $request, $id)
    {
        try {
            $bus = Bus::find($id);
            
            if (!$bus) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bus tidak ditemukan'
                ], 404);
            }

            $validator = Validator::make($request->all(), [
                'schedule_id' => 'required|exists:bus_schedules,id',
                'seat_ids' => 'required|array|min:1',
                'seat_ids.*' => 'exists:bus_seats,id',
                'notes' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            $schedule = BusSchedule::find($request->schedule_id);
            
            // Check if seats are available
            $bookedSeats = \App\Models\BusBookingSeat::where('bus_schedule_id', $request->schedule_id)
                ->whereIn('bus_seat_id', $request->seat_ids)
                ->where('status', '!=', 'cancelled')
                ->pluck('bus_seat_id')
                ->toArray();

            if (!empty($bookedSeats)) {
                $bookedCodes = BusSeat::whereIn('id', $bookedSeats)->pluck('seat_code')->toArray();
                return response()->json([
                    'success' => false,
                    'message' => 'Kursi sudah dipesan: ' . implode(', ', $bookedCodes)
                ], 400);
            }

            // Calculate total price
            $totalPrice = $schedule->price * count($request->seat_ids);

            // Create booking
            $booking = \App\Models\Booking::create([
                'user_id' => $request->user()->id,
                'type' => 'bus',
                'item_id' => $id,
                'booking_code' => 'MYT-' . strtoupper(\Illuminate\Support\Str::random(8)),
                'total_price' => $totalPrice,
                'status' => 'pending',
                'notes' => $request->notes
            ]);

            // Create booking seats
            foreach ($request->seat_ids as $seatId) {
                $seat = BusSeat::find($seatId);
                \App\Models\BusBookingSeat::create([
                    'booking_id' => $booking->id,
                    'bus_seat_id' => $seatId,
                    'bus_schedule_id' => $request->schedule_id,
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
            Log::error('Book bus seats error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
}