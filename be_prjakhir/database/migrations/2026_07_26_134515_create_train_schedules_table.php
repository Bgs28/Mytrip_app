// database/migrations/xxxx_xx_xx_create_train_schedules_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('train_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('train_id')->constrained()->onDelete('cascade');
            $table->date('departure_date');
            $table->time('departure_time');
            $table->time('arrival_time');
            $table->integer('available_seats')->default(0);
            $table->decimal('price_modifier', 5, 2)->default(1.00); // 1.00 = 100%, 0.90 = 90%, 1.10 = 110%
            $table->enum('status', ['active', 'cancelled', 'full'])->default('active');
            $table->timestamps();
            
            $table->unique(['train_id', 'departure_date', 'departure_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('train_schedules');
    }
};