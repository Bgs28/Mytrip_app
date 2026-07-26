// database/migrations/xxxx_xx_xx_create_rooms_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained()->onDelete('cascade');
            $table->string('room_number')->unique();
            $table->enum('room_type', ['standard', 'deluxe', 'suite', 'family', 'presidential']);
            $table->string('room_name');
            $table->text('description')->nullable();
            $table->integer('price_per_night');
            $table->integer('capacity')->default(2);
            $table->enum('bed_type', ['single', 'double', 'twin', 'queen', 'king'])->default('double');
            $table->integer('size')->nullable();
            $table->json('facilities')->nullable();
            $table->json('images')->nullable(); // Untuk multiple images
            $table->string('thumbnail')->nullable(); // Untuk thumbnail utama
            $table->boolean('is_available')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};