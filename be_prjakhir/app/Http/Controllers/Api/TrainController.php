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
        Log::info('Get train schedules called', ['train_id' => $id]);

        $train = Train::find($id);
        
        if (!$train) {
            return response()->json([
                'success' => false,
                'message' => 'Kereta tidak ditemukan'
            ], 404);
        }

        // Get schedules for this train (tanggal hari ini dan ke depan)
        $schedules = TrainSchedule::where('train_id', $id)
            ->where('departure_date', '>=', now()->toDateString())
            ->orderBy('departure_date')
            ->orderBy('departure_time')
            ->get();

        Log::info('Train schedules found', ['count' => $schedules->count()]);

        // Jika tidak ada schedules, generate otomatis
        if ($schedules->isEmpty()) {
            Log::info('No schedules found, generating...');
            $train->generateSchedules();
            
            // Ambil ulang setelah generate
            $schedules = TrainSchedule::where('train_id', $id)
                ->where('departure_date', '>=', now()->toDateString())
                ->orderBy('departure_date')
                ->orderBy('departure_time')
                ->get();
            
            Log::info('Schedules after generate', ['count' => $schedules->count()]);
        }

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
    /**
 * Get train seats with availability for a schedule
 */
public function getSeats(Request $request, $id)
{
    try {
        Log::info('Get train seats called', [
            'train_id' => $id,
            'schedule_id' => $request->schedule_id
        ]);

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
        
        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }
        
        // Get all seats for this train
        $seats = TrainSeat::where('train_id', $id)->get();
        
        // Jika tidak ada seats, generate otomatis
        if ($seats->isEmpty()) {
            Log::info('No seats found, generating...');
            $train->generateSeats();
            $seats = TrainSeat::where('train_id', $id)->get();
        }
        
        // Check which seats are booked for this schedule
        $bookedSeats = \App\Models\TrainBookingSeat::where('train_schedule_id', $request->schedule_id)
            ->where('status', '!=', 'cancelled')
            ->pluck('train_seat_id')
            ->toArray();

        // Map seat data with availability
        $seatData = $seats->map(function($seat) use ($bookedSeats, $schedule) {
            $isBooked = in_array($seat->id, $bookedSeats);
            $isAvailable = !$isBooked && $seat->is_available;
            
            return [
                'id' => $seat->id,
                'seat_code' => $seat->seat_code,
                'seat_number' => $seat->seat_number,
                'position' => $seat->position,
                'is_available' => $isAvailable,
                'is_booked' => $isBooked,
            ];
        });

        Log::info('Train seats loaded', [
            'total_seats' => $seats->count(),
            'booked_seats' => count($bookedSeats),
            'available_seats' => $schedule->available_seats
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kursi kereta berhasil dimuat',
            'data' => [
                'seats' => $seatData,
                'schedule' => [
                    'id' => $schedule->id,
                    'available_seats' => $schedule->available_seats,
                    'total_seats' => $train->seat,
                ]
            ]
        ]);

    } catch (\Exception $e) {
        Log::error('Get train seats error: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
}

    /**
 * Book train seats - FIX
 */
public function bookSeats(Request $request, $id)
{
    try {
        Log::info('Book train seats called', [
            'train_id' => $id,
            'user_id' => $request->user()->id,
            'request' => $request->all()
        ]);

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
            Log::error('Validation failed', ['errors' => $validator->errors()->toArray()]);
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $schedule = TrainSchedule::find($request->schedule_id);
        
        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }

        // Cek apakah kursi masih tersedia
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

        // Cek apakah kursi masih tersedia di schedule
        if ($schedule->available_seats < count($request->seat_ids)) {
            return response()->json([
                'success' => false,
                'message' => 'Kursi tidak mencukupi. Sisa: ' . $schedule->available_seats
            ], 400);
        }

        // Hitung total harga
        $totalPrice = $schedule->price * count($request->seat_ids);

        // Create booking
        $booking = \App\Models\Booking::create([
            'user_id' => $request->user()->id,
            'type' => 'train',
            'item_id' => $id,
            'booking_code' => 'MYT-' . strtoupper(\Illuminate\Support\Str::random(8)),
            'total_price' => $totalPrice,
            'status' => 'pending',
            'notes' => $request->notes
        ]);

        Log::info('Booking created', ['booking_id' => $booking->id]);

        // Create booking seats
        $bookingSeats = [];
        foreach ($request->seat_ids as $seatId) {
            $seat = TrainSeat::find($seatId);
            if ($seat) {
                $bookingSeats[] = [
                    'booking_id' => $booking->id,
                    'train_seat_id' => $seatId,
                    'train_schedule_id' => $request->schedule_id,
                    'seat_code' => $seat->seat_code,
                    'price' => $schedule->price,
                    'status' => 'pending',
                    'created_at' => now(),
                    'updated_at' => now()
                ];
            }
        }

        if (!empty($bookingSeats)) {
            \App\Models\TrainBookingSeat::insert($bookingSeats);
            Log::info('Booking seats created', ['count' => count($bookingSeats)]);
        }

        // UPDATE available_seats
        $schedule->decrement('available_seats', count($request->seat_ids));

        $booking->load('trainBookingSeats');

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibuat',
            'data' => [
                'booking' => $booking,
                'total_price' => $totalPrice,
                'seats' => count($request->seat_ids),
                'available_seats' => $schedule->fresh()->available_seats,
                'booking_seats' => $bookingSeats
            ]
        ], 201);

    } catch (\Exception $e) {
        Log::error('Book train seats error: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
    }
}