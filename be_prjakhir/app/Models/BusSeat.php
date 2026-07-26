<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BusSeat extends Model
{
    protected $fillable = [
        'bus_id',
        'seat_number',
        'seat_type',
        'position',
        'seat_code',
        'is_available'
    ];

    protected $casts = [
        'is_available' => 'boolean'
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

    // Accessor untuk label seat type
    public function getSeatTypeLabelAttribute()
    {
        $labels = [
            'regular' => 'Regular',
            'premium' => 'Premium',
            'executive' => 'Eksekutif'
        ];
        return $labels[$this->seat_type] ?? $this->seat_type;
    }

    // Accessor untuk label position
    public function getPositionLabelAttribute()
    {
        $labels = [
            'window' => 'Jendela',
            'middle' => 'Tengah',
            'aisle' => 'Lorong'
        ];
        return $labels[$this->position] ?? $this->position;
    }
}