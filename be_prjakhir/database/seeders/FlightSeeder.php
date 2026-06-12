<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Flight;


class FlightSeeder extends Seeder
{
    public function run(): void
    {
        Flight::create([
            'airline'=>'Garuda Indonesia',
            'from'=>'Padang',
            'destination'=>'Jakarta',
            'departure_time'=>'08:00',
            'arrival_time'=>'10:00',
            'price'=>850000,
            'seat'=>120,
            'image'=>'garuda.jpg'
        ]);


        Flight::create([
            'airline'=>'Lion Air',
            'from'=>'Padang',
            'destination'=>'Bali',
            'departure_time'=>'12:00',
            'arrival_time'=>'15:00',
            'price'=>700000,
            'seat'=>100,
            'image'=>'lion.jpg'
        ]);
    }
}