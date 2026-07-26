<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrainSeat extends Model
{
    protected $fillable = [
        'train_id',
        'seat_number',
        'seat_class',
        'position',
        'seat_code',
        'is_available'
    ];

    protected $casts = [
        'is_available' => 'boolean'
    ];

    // Relasi ke Train
    public function train()
    {
        return $this->belongsTo(Train::class);
    }

    // Relasi ke Booking Seats
    public function bookingSeats()
    {
        return $this->hasMany(TrainBookingSeat::class);
    }

    // Accessor untuk label seat class
    public function getSeatClassLabelAttribute()
    {
        $labels = [
            'economy' => 'Ekonomi',
            'business' => 'Bisnis',
            'executive' => 'Eksekutif'
        ];
        return $labels[$this->seat_class] ?? $this->seat_class;
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