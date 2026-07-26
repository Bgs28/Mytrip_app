// database/migrations/xxxx_xx_xx_create_bus_seats_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bus_seats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bus_id')->constrained()->onDelete('cascade');
            $table->string('seat_number');
            $table->enum('seat_type', ['regular', 'premium', 'executive'])->default('regular');
            $table->enum('position', ['window', 'middle', 'aisle'])->default('window');
            $table->string('seat_code')->unique(); // Contoh: A1, B2, C3
            $table->boolean('is_available')->default(true);
            $table->timestamps();
            
            $table->unique(['bus_id', 'seat_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bus_seats');
    }
};