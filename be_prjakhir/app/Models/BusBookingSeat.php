<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BusBookingSeat extends Model
{
    protected $fillable = [
        'booking_id',
        'bus_seat_id',
        'bus_schedule_id',
        'seat_code',
        'price',
        'status'
    ];

    protected $casts = [
        'price' => 'decimal:2'
    ];

    // Relasi ke Booking
    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    // Relasi ke BusSeat
    public function busSeat()
    {
        return $this->belongsTo(BusSeat::class);
    }

    // Relasi ke BusSchedule
    public function busSchedule()
    {
        return $this->belongsTo(BusSchedule::class);
    }

    // Accessor untuk status label
    public function getStatusLabelAttribute()
    {
        $labels = [
            'pending' => 'Pending',
            'confirmed' => 'Confirmed',
            'cancelled' => 'Cancelled'
        ];
        return $labels[$this->status] ?? $this->status;
    }
}