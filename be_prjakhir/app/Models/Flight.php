<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Flight extends Model
{
    protected $fillable = [
        'airline',
        'from',
        'destination',
        'departure_time',
        'arrival_time',
        'price',
        'seat',
        'image'
    ];
}
