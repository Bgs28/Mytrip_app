<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Bus;


class BusSeeder extends Seeder
{

public function run(): void
{

Bus::create([
    'bus_name'=>'Sinar Jaya',
    'from'=>'Padang',
    'destination'=>'Pekanbaru',
    'departure_time'=>'20:00',
    'price'=>250000,
    'seat'=>40
]);

}

}