<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ETicket extends Model
{
    protected $fillable = [
        'booking_id',
        'user_id',
        'ticket_code',
        'qr_code',
        'valid_from',
        'valid_until',
        'is_used',
        'used_at',
        'check_in_code'
    ];

    protected $casts = [
        'valid_from' => 'datetime',
        'valid_until' => 'datetime',
        'used_at' => 'datetime',
        'is_used' => 'boolean'
    ];

    // Relasi ke Booking
    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Generate ticket code
    public static function generateTicketCode()
    {
        $prefix = 'MYT';
        $random = strtoupper(substr(uniqid(), -6));
        return $prefix . '-' . $random;
    }

    // Generate check-in code (6 digit angka)
    public static function generateCheckInCode()
    {
        return str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
    }
}
