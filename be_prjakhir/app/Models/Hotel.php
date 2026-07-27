<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Hotel extends Model
{
    protected $fillable = [
        'name',
        'location',
        'description',
        'rating',
        'image',
        'check_in_time',
        'check_out_time',
        'facilities',
        'phone',
        'email',
        'address',
        'images'
    ];

    protected $casts = [
        'rating' => 'decimal:2',
        'facilities' => 'array',
        'images' => 'array'
    ];

    // Relasi ke Room
    public function rooms()
    {
        return $this->hasMany(Room::class);
    }

    // Get harga termurah dari semua kamar
    public function getMinPriceAttribute()
    {
        return $this->rooms()->min('price_per_night') ?? 0;
    }

    // Get harga termahal dari semua kamar
    public function getMaxPriceAttribute()
    {
        return $this->rooms()->max('price_per_night') ?? 0;
    }

    // Get range harga
    public function getPriceRangeAttribute()
    {
        $min = $this->min_price;
        $max = $this->max_price;
        
        if ($min == 0 && $max == 0) {
            return 'Harga belum tersedia';
        }
        
        if ($min == $max) {
            return 'Rp ' . number_format($min, 0, ',', '.');
        }
        
        return 'Rp ' . number_format($min, 0, ',', '.') . ' - Rp ' . number_format($max, 0, ',', '.');
    }

    // Accessor untuk image URL
    public function getImageUrlAttribute()
    {
        if ($this->image) {
            return asset('storage/hotels/' . $this->image);
        }
        return asset('images/default-hotel.jpg');
    }

    // Accessor untuk images URL
    public function getImagesUrlAttribute()
    {
        if ($this->images && is_array($this->images)) {
            return array_map(function($image) {
                return asset('storage/hotels/' . $image);
            }, $this->images);
        }
        return [];
    }

    // Accessor untuk rating bintang
    public function getStarsAttribute()
    {
        $rating = $this->rating ?? 0;
        $fullStars = floor($rating);
        $halfStar = $rating - $fullStars >= 0.5 ? 1 : 0;
        $emptyStars = 5 - $fullStars - $halfStar;
        
        return [
            'full' => $fullStars,
            'half' => $halfStar,
            'empty' => $emptyStars
        ];
    }
}