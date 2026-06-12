<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Hotel;

class HotelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Hotel::create([
            'name'=>'Bali Resort Hotel',
            'location'=>'Bali',
            'description'=>'Hotel dekat pantai',
            'price'=>800000,
            'rating'=>4.8,
            'image'=>'bali.jpg'
        ]);

        Hotel::create([
            'name'=>'Jakarta City Hotel',
            'location'=>'Jakarta',
            'description'=>'Hotel pusat kota',
            'price'=>500000,
            'rating'=>4.5,
            'image'=>'jakarta.jpg'
        ]);
    }
}
