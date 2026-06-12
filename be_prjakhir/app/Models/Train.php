<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Train extends Model
{
    protected $fillable = [
        'train_name',
        'from',
        'destination',
        'departure_time',
        'arrival_time',
        'price',
        'seat'
    ];
}