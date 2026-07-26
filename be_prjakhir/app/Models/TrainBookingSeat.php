<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrainBookingSeat extends Model
{
    protected $fillable = [
        'booking_id',
        'train_seat_id',
        'train_schedule_id',
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

    // Relasi ke TrainSeat
    public function trainSeat()
    {
        return $this->belongsTo(TrainSeat::class);
    }

    // Relasi ke TrainSchedule
    public function trainSchedule()
    {
        return $this->belongsTo(TrainSchedule::class);
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