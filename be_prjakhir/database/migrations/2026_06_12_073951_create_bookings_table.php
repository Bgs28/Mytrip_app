<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('bookings', function (Blueprint $table) {

        $table->id();


        // user yang booking
        $table->foreignId('user_id')
              ->constrained()
              ->cascadeOnDelete();


        // tipe layanan
        $table->enum('type',[
            'flight',
            'train',
            'bus',
            'hotel'
        ]);


        // id barang yang dibooking
        $table->unsignedBigInteger('item_id');


        $table->string('booking_code')
              ->unique();


        $table->integer('total_price');


        $table->enum('status',[
            'pending',
            'paid',
            'cancel'
        ])->default('pending');


        $table->timestamps();

    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
