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
}
