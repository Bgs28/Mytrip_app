<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bus extends Model
{
    protected $fillable = [
        'bus_name',
        'from',
        'destination',
        'departure_time',
        'price',
        'seat'
    ];
}