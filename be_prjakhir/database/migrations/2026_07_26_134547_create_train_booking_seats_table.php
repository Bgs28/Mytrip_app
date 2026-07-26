// database/migrations/xxxx_xx_xx_create_train_booking_seats_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('train_booking_seats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->foreignId('train_seat_id')->constrained()->onDelete('cascade');
            $table->foreignId('train_schedule_id')->constrained()->onDelete('cascade');
            $table->string('seat_code');
            $table->decimal('price', 10, 2);
            $table->enum('status', ['pending', 'confirmed', 'cancelled'])->default('pending');
            $table->timestamps();
            
            $table->unique(['train_schedule_id', 'train_seat_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('train_booking_seats');
    }
};