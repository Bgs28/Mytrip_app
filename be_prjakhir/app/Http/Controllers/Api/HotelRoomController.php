<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use App\Models\Room;
use App\Models\RoomBooking;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class HotelRoomController extends Controller
{
    // Get all rooms for a hotel
    public function getHotelRooms(Request $request, $hotelId)
    {
        $hotel = Hotel::find($hotelId);
        
        if (!$hotel) {
            return response()->json([
                'success' => false,
                'message' => 'Hotel tidak ditemukan'
            ], 404);
        }

        $rooms = Room::where('hotel_id', $hotelId)
            ->where('is_available', true)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar kamar hotel berhasil dimuat',
            'data' => [
                'hotel' => $hotel,
                'rooms' => $rooms
            ]
        ]);
    }

    // Check room availability for dates
    public function checkAvailability(Request $request, $roomId)
    {
        $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in'
        ]);

        $room = Room::find($roomId);
        
        if (!$room) {
            return response()->json([
                'success' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        $isAvailable = $room->isAvailableForDates($request->check_in, $request->check_out);

        return response()->json([
            'success' => true,
            'message' => $isAvailable ? 'Kamar tersedia' : 'Kamar tidak tersedia untuk tanggal tersebut',
            'data' => [
                'room' => $room,
                'is_available' => $isAvailable,
                'check_in' => $request->check_in,
                'check_out' => $request->check_out
            ]
        ]);
    }

    // Book a room
    public function bookRoom(Request $request)
    {
        try {
            $request->validate([
                'room_id' => 'required|exists:rooms,id',
                'check_in' => 'required|date|after_or_equal:today',
                'check_out' => 'required|date|after:check_in',
                'guests_count' => 'required|integer|min:1',
                'guest_names' => 'nullable|array',
                'notes' => 'nullable|string'
            ]);

            $room = Room::find($request->room_id);
            
            if (!$room) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kamar tidak ditemukan'
                ], 404);
            }

            // Cek ketersediaan
            if (!$room->isAvailableForDates($request->check_in, $request->check_out)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kamar tidak tersedia untuk tanggal tersebut'
                ], 400);
            }

            // Hitung total malam
            $checkIn = new \DateTime($request->check_in);
            $checkOut = new \DateTime($request->check_out);
            $nights = $checkIn->diff($checkOut)->days;
            $totalPrice = $room->price_per_night * $nights;

            // Create Booking
            $booking = Booking::create([
                'user_id' => $request->user()->id,
                'type' => 'hotel',
                'item_id' => $room->hotel_id,
                'booking_code' => 'MYT-' . strtoupper(Str::random(8)),
                'total_price' => $totalPrice,
                'status' => 'pending',
                'notes' => $request->notes
            ]);

            // Create Room Booking
            $roomBooking = RoomBooking::create([
                'room_id' => $room->id,
                'booking_id' => $booking->id,
                'check_in_date' => $request->check_in,
                'check_out_date' => $request->check_out,
                'total_price' => $totalPrice,
                'guests_count' => $request->guests_count,
                'guest_names' => $request->guest_names,
                'status' => 'pending'
            ]);

            Log::info('Room booked successfully', [
                'room_id' => $room->id,
                'booking_id' => $booking->id,
                'room_booking_id' => $roomBooking->id
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking kamar berhasil',
                'data' => [
                    'booking' => $booking,
                    'room_booking' => $roomBooking,
                    'room' => $room,
                    'nights' => $nights,
                    'total_price' => $totalPrice
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Room booking error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get room booking detail
    public function getRoomBookingDetail(Request $request, $id)
    {
        $roomBooking = RoomBooking::with(['room', 'room.hotel', 'booking'])
            ->whereHas('booking', function($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->find($id);

        if (!$roomBooking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking kamar tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail booking kamar berhasil diambil',
            'data' => $roomBooking
        ]);
    }
}