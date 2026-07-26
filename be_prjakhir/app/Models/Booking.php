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
        'status'
    ];


    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function eTicket()
    {
        return $this->hasOne(ETicket::class);
    }

    public function promo(){
        return $this->belongsTo(Promo::class);
    }

    // Relasi ke Room Booking (untuk hotel)
    public function roomBooking()
    {
        return $this->hasOne(RoomBooking::class);
    }
}
