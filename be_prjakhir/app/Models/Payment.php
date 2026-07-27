<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id',
        'user_id',
        'promo_id',
        'invoice_number',
        'base_amount',
        'discount_amount',
        'total_amount',
        'payment_method',
        'status',
        'proof_of_payment',
        'paid_at',
        'notes'
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

    // Accessor untuk payment method label
    public function getPaymentMethodLabelAttribute()
    {
        $methods = [
            'bank_transfer_bca' => 'Bank Transfer BCA',
            'bank_transfer_mandiri' => 'Bank Transfer Mandiri',
            'bank_transfer_bni' => 'Bank Transfer BNI',
            'ovo' => 'OVO',
            'gopay' => 'GoPay'
        ];
        return $methods[$this->payment_method] ?? $this->payment_method;
    }

    // Accessor untuk status label
    public function getStatusLabelAttribute()
    {
        $statuses = [
            'pending' => 'Menunggu Verifikasi',
            'paid' => 'Lunas',
            'failed' => 'Gagal',
            'refunded' => 'Dibatalkan'
        ];
        return $statuses[$this->status] ?? $this->status;
    }

    // Accessor untuk proof URL
    public function getProofUrlAttribute()
    {
        if ($this->proof_of_payment) {
            return asset('storage/payments/' . $this->proof_of_payment);
        }
        return null;
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