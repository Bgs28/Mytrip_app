<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Promo extends Model
{
    protected $fillable = [
        'code', 'name', 'description', 'discount_type', 'discount_value',
        'min_purchase', 'max_discount', 'target_type', 'start_date', 'end_date',
        'usage_limit', 'usage_count', 'is_active'
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'discount_value' => 'decimal:2',
        'min_purchase' => 'decimal:2',
        'max_discount' => 'decimal:2'
    ];

    // Relasi ke Booking
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Cek apakah promo valid
    public function isValid($totalPrice = null)
    {
        $now = now();
        
        // Cek status aktif
        if (!$this->is_active) return false;
        
        // Cek tanggal
        if ($now < $this->start_date || $now > $this->end_date) return false;
        
        // Cek limit penggunaan
        if ($this->usage_limit && $this->usage_count >= $this->usage_limit) return false;
        
        // Cek minimal pembelian
        if ($totalPrice && $totalPrice < $this->min_purchase) return false;
        
        return true;
    }

    // Hitung diskon
    public function calculateDiscount($totalPrice)
    {
        if (!$this->isValid($totalPrice)) return 0;

        if ($this->discount_type === 'percentage') {
            $discount = ($totalPrice * $this->discount_value) / 100;
            
            // Cek max discount
            if ($this->max_discount && $discount > $this->max_discount) {
                $discount = $this->max_discount;
            }
            
            return $discount;
        }
        
        // Fixed discount
        return min($this->discount_value, $totalPrice);
    }
}
