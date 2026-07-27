<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'item_id',
        'booking_code',
        'total_price',
        'status',
        'promo_id',
        'discount_amount'
        // 'notes'
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi ke Payment (One to One)
    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    // Relasi ke Promo
    public function promo()
    {
        return $this->belongsTo(Promo::class);
    }

    // Relasi ke E-Ticket
    public function eTicket()
    {
        return $this->hasOne(ETicket::class);
    }

    // Relasi ke Room Booking (untuk hotel)
    public function roomBooking()
    {
        return $this->hasOne(RoomBooking::class);
    }

    // Relasi ke Train Booking Seats
    public function trainBookingSeats()
    {
        return $this->hasMany(TrainBookingSeat::class);
    }

    // Relasi ke Bus Booking Seats
    public function busBookingSeats()
    {
        return $this->hasMany(BusBookingSeat::class);
    }

    // Accessor untuk status label
    public function getStatusLabelAttribute()
    {
        $statuses = [
            'pending' => 'Menunggu Pembayaran',
            'paid' => 'Lunas',
            'cancel' => 'Dibatalkan'
        ];
        return $statuses[$this->status] ?? $this->status;
    }

    // Accessor untuk type label
    public function getTypeLabelAttribute()
    {
        $types = [
            'bus' => 'Bus',
            'train' => 'Kereta Api',
            'hotel' => 'Hotel'
        ];
        return $types[$this->type] ?? $this->type;
    }

    // Accessor untuk type icon
    public function getTypeIconAttribute()
    {
        $icons = [
            'bus' => '🚌',
            'train' => '🚆',
            'hotel' => '🏨'
        ];
        return $icons[$this->type] ?? '📋';
    }
}