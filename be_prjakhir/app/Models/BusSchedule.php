<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BusSchedule extends Model
{
    protected $fillable = [
        'bus_id',
        'departure_date',
        'departure_time',
        'arrival_time',
        'available_seats',
        'price',
        'status'
    ];

    protected $casts = [
        'departure_date' => 'date',
        'departure_time' => 'datetime:H:i',
        'arrival_time' => 'datetime:H:i',
        'price_modifier' => 'decimal:2'
    ];

    // Relasi ke Bus
    public function bus()
    {
        return $this->belongsTo(Bus::class);
    }

    // Relasi ke Booking Seats
    public function bookingSeats()
    {
        return $this->hasMany(BusBookingSeat::class);
    }

    // Hitung total kursi terisi
    public function getBookedSeatsCountAttribute()
    {
        return $this->bookingSeats()
            ->where('status', '!=', 'cancelled')
            ->count();
    }

    // Hitung sisa kursi
    public function getRemainingSeatsAttribute()
    {
        return $this->available_seats - $this->booked_seats_count;
    }

    // Cek ketersediaan kursi
    public function isSeatAvailable($seatId)
    {
        return !$this->bookingSeats()
            ->where('bus_seat_id', $seatId)
            ->where('status', '!=', 'cancelled')
            ->exists();
    }
}