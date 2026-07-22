<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id', 'user_id', 'promo_id', 'invoice_number', 'base_amount',
        'discount_amount', 'total_amount', 'payment_method', 'status',
        'proof_of_payment', 'paid_at', 'notes'
    ];

    protected $casts = [
        'base_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'paid_at' => 'datetime'
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

    // Relasi ke Promo
    public function promo()
    {
        return $this->belongsTo(Promo::class);
    }

    // Generate invoice number
    public static function generateInvoiceNumber()
    {
        $prefix = 'INV-' . date('Ymd');
        $lastPayment = self::where('invoice_number', 'LIKE', $prefix . '%')
            ->orderBy('id', 'desc')
            ->first();
            
        if (!$lastPayment) {
            return $prefix . '-0001';
        }
        
        $lastNumber = intval(substr($lastPayment->invoice_number, -4));
        $newNumber = str_pad($lastNumber + 1, 4, '0', STR_PAD_LEFT);
        
        return $prefix . '-' . $newNumber;
    }
}
