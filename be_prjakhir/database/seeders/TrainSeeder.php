<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Train;


class TrainSeeder extends Seeder
{
    public function run(): void
    {

        Train::create([
            'train_name'=>'Argo Parahyangan',
            'from'=>'Bandung',
            'destination'=>'Jakarta',
            'departure_time'=>'07:00',
            'arrival_time'=>'10:30',
            'price'=>150000,
            'seat'=>200
        ]);

    }
}