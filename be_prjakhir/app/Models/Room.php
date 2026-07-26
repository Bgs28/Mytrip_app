<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    protected $fillable = [
        'hotel_id',
        'room_number',
        'room_type',
        'room_name',
        'description',
        'price_per_night',
        'capacity',
        'bed_type',
        'size',
        'facilities',
        'images',
        'thumbnail',
        'is_available'
    ];

    protected $casts = [
        'facilities' => 'array',
        'images' => 'array',
        'is_available' => 'boolean'
    ];

    // Relasi ke Hotel
    public function hotel()
    {
        return $this->belongsTo(Hotel::class);
    }

    // Relasi ke RoomBooking
    public function roomBookings()
    {
        return $this->hasMany(RoomBooking::class);
    }

    // Cek ketersediaan kamar untuk tanggal tertentu
    public function isAvailableForDates($checkIn, $checkOut)
    {
        $overlapping = $this->roomBookings()
            ->where('status', '!=', 'cancelled')
            ->where(function($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in_date', [$checkIn, $checkOut])
                      ->orWhereBetween('check_out_date', [$checkIn, $checkOut])
                      ->orWhere(function($q) use ($checkIn, $checkOut) {
                          $q->where('check_in_date', '<=', $checkIn)
                            ->where('check_out_date', '>=', $checkOut);
                      });
            })
            ->exists();

        return !$overlapping && $this->is_available;
    }

    // Accessor untuk label room type
    public function getRoomTypeLabelAttribute()
    {
        $labels = [
            'standard' => 'Standard',
            'deluxe' => 'Deluxe',
            'suite' => 'Suite',
            'family' => 'Family',
            'presidential' => 'Presidential'
        ];
        return $labels[$this->room_type] ?? $this->room_type;
    }

    // Accessor untuk label bed type
    public function getBedTypeLabelAttribute()
    {
        $labels = [
            'single' => 'Single Bed',
            'double' => 'Double Bed',
            'twin' => 'Twin Beds',
            'queen' => 'Queen Bed',
            'king' => 'King Bed'
        ];
        return $labels[$this->bed_type] ?? $this->bed_type;
    }

    // Accessor untuk thumbnail URL
    public function getThumbnailUrlAttribute()
    {
        if ($this->thumbnail) {
            return asset('storage/rooms/' . $this->thumbnail);
        }
        
        // Default image
        return asset('images/default-room.jpg');
    }

    // Accessor untuk images URL
    public function getImagesUrlAttribute()
    {
        if ($this->images && is_array($this->images)) {
            return array_map(function($image) {
                return asset('storage/rooms/' . $image);
            }, $this->images);
        }
        return [];
    }
}