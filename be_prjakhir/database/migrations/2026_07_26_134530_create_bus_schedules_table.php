// database/migrations/xxxx_xx_xx_create_bus_schedules_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bus_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bus_id')->constrained()->onDelete('cascade');
            $table->date('departure_date');
            $table->time('departure_time');
            $table->time('arrival_time');
            $table->integer('available_seats')->default(0);
            $table->decimal('price_modifier', 5, 2)->default(1.00);
            $table->enum('status', ['active', 'cancelled', 'full'])->default('active');
            $table->timestamps();
            
            $table->unique(['bus_id', 'departure_date', 'departure_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bus_schedules');
    }
};