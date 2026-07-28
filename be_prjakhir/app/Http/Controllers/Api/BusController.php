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
        if ($request->filled('from')) {
            $query->where('from', 'LIKE', '%' . $request->from . '%');
        }

        // Filter Kota Tujuan (jika dicari di Flutter)
        if ($request->filled('destination')) {
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

/* * Get bus seats with availability for a schedule
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
        $seatData = $seats->map(function($seat) use ($bookedSeats, $schedule) {
            // Cek apakah kursi sudah dipesan
            $isBooked = in_array($seat->id, $bookedSeats);
            
            // Cek apakah kursi tersedia (belum dipesan dan is_available true)
            $isAvailable = !$isBooked && $seat->is_available;
            
            return [
                'id' => $seat->id,
                'seat_code' => $seat->seat_code,
                'seat_number' => $seat->seat_number,
                'position' => $seat->position,
                'is_available' => $isAvailable,
                'is_booked' => $isBooked, // Tambahkan flag khusus booked
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Kursi bus berhasil dimuat',
            'data' => [
                'seats' => $seatData,
                'schedule' => [
                    'id' => $schedule->id,
                    'available_seats' => $schedule->available_seats,
                    'total_seats' => $bus->seat,
                ]
            ]
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
 * Book bus seats - FIX
 */
public function bookSeats(Request $request, $id)
{
    try {
        Log::info('Book bus seats called', [
            'bus_id' => $id,
            'user_id' => $request->user()->id,
            'request' => $request->all()
        ]);

        $bus = Bus::find($id);
        
        if (!$bus) {
            return response()->json([
                'success' => false,
                'message' => 'Bus tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'schedule_id' => 'required|exists:bus_schedules,id',
            'seat_ids'    => 'required|array|min:1',
            'seat_ids.*'  => 'exists:bus_seats,id',
            'booking_id'  => 'nullable|exists:bookings,id',
            'notes'       => 'nullable|string'
        ]);

        if ($validator->fails()) {
            Log::error('Validation failed', ['errors' => $validator->errors()->toArray()]);
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $schedule = BusSchedule::find($request->schedule_id);
        
        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }

        // Cek apakah kursi masih tersedia
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

        // Cek apakah kursi masih tersedia di schedule
        if ($schedule->available_seats < count($request->seat_ids)) {
            return response()->json([
                'success' => false,
                'message' => 'Kursi tidak mencukupi. Sisa: ' . $schedule->available_seats
            ], 400);
        }

        // Hitung total harga
        $totalPrice = $schedule->price * count($request->seat_ids);

        // Gunakan booking yang sudah ada, atau buat baru jika booking_id tidak dikirim
        if ($request->filled('booking_id')) {
            $booking = \App\Models\Booking::where('id', $request->booking_id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan atau bukan milik Anda'
                ], 404);
            }

            // Update total price sesuai kursi yang dipilih
            $booking->update(['total_price' => $totalPrice]);
            Log::info('Using existing booking', ['booking_id' => $booking->id]);
        } else {
            $booking = \App\Models\Booking::create([
                'user_id'      => $request->user()->id,
                'type'         => 'bus',
                'item_id'      => $id,
                'booking_code' => 'MYT-' . strtoupper(\Illuminate\Support\Str::random(8)),
                'total_price'  => $totalPrice,
                'status'       => 'pending',
                'notes'        => $request->notes
            ]);
            Log::info('New booking created', ['booking_id' => $booking->id]);
        }

        // Create booking seats - INI YANG PENTING
        $bookingSeats = [];
        foreach ($request->seat_ids as $seatId) {
            $seat = BusSeat::find($seatId);
            if ($seat) {
                $bookingSeats[] = [
                    'booking_id' => $booking->id,
                    'bus_seat_id' => $seatId,
                    'bus_schedule_id' => $request->schedule_id,
                    'seat_code' => $seat->seat_code,
                    'price' => $schedule->price,
                    'status' => 'pending',
                    'created_at' => now(),
                    'updated_at' => now()
                ];
            }
        }

        if (!empty($bookingSeats)) {
            \App\Models\BusBookingSeat::insert($bookingSeats);
            Log::info('Booking seats created', ['count' => count($bookingSeats)]);
        }

        // UPDATE available_seats - Kurangi jumlah kursi
        $schedule->decrement('available_seats', count($request->seat_ids));

        // Load booking dengan relasi
        $booking->load('busBookingSeats');

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
        Log::error('Book bus seats error: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
    }
}