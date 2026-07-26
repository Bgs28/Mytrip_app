<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Hotel extends Model
{
    protected $fillable = [
        'name',
        'location',
        'description',
        'price',
        'rating',
        'image',
        'check_in_time',
        'check_out_time',
        'facilities'
    ];

    protected $casts = [
        'rating' => 'decimal:2',
        'facilities' => 'array'
    ];

    // Relasi ke Room
    public function rooms()
    {
        return $this->hasMany(Room::class);
    }

    // Relasi ke Booking melalui RoomBooking
    public function bookings()
    {
        return $this->hasManyThrough(Booking::class, RoomBooking::class, 'room_id', 'id', 'id', 'booking_id');
    }
}