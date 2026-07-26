<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrainSchedule extends Model
{
    protected $fillable = [
        'train_id',
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
        'price' => 'decimal:2'
    ];

    // Relasi ke Train
    public function train()
    {
        return $this->belongsTo(Train::class);
    }

    // Relasi ke TrainBookingSeat
    public function bookingSeats()
    {
        return $this->hasMany(TrainBookingSeat::class);
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
            ->where('train_seat_id', $seatId)
            ->where('status', '!=', 'cancelled')
            ->exists();
    }
}