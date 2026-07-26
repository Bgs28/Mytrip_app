// database/migrations/xxxx_xx_xx_create_train_seats_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('train_seats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('train_id')->constrained()->onDelete('cascade');
            $table->string('seat_number');
            $table->enum('seat_class', ['economy', 'business', 'executive'])->default('economy');
            $table->enum('position', ['window', 'middle', 'aisle'])->default('window');
            $table->string('seat_code')->unique(); // Contoh: A1, B2, C3
            $table->boolean('is_available')->default(true);
            $table->timestamps();
            
            $table->unique(['train_id', 'seat_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('train_seats');
    }
};