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
        'max_discount' => 'decimal:2',
        'is_active' => 'boolean'
    ];

    // Relasi ke Booking
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Relasi ke Payment
    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    // Cek apakah promo valid - FIX
   public function isValid($totalPrice = null)
{
    // Gunakan timezone Asia/Jakarta
    $now = now('Asia/Jakarta');
    
    // Cek status aktif (gunakan is_active dari database)
    if (!$this->is_active) {
        return false;
    }
    
    // Cek tanggal - pastikan menggunakan compare yang benar
    if ($this->start_date->gt($now)) {
        return false;
    }
    
    if ($this->end_date->lt($now)) {
        return false;
    }
    
    // Cek limit penggunaan
    if ($this->usage_limit && $this->usage_count >= $this->usage_limit) {
        return false;
    }
    
    // Cek minimal pembelian
    if ($totalPrice !== null && $totalPrice < $this->min_purchase) {
        return false;
    }
    
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

    // Accessor untuk label target
    public function getTargetLabelAttribute()
    {
        $labels = [
            'all' => 'Semua',
            'bus' => 'Bus',
            'train' => 'Kereta Api',
            'hotel' => 'Hotel'
        ];
        return $labels[$this->target_type] ?? $this->target_type;
    }

    // Accessor untuk label discount type
    public function getDiscountTypeLabelAttribute()
    {
        return $this->discount_type === 'percentage' ? 'Persentase (%)' : 'Nominal (Rp)';
    }

    // Scope untuk promo aktif
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now());
    }
}