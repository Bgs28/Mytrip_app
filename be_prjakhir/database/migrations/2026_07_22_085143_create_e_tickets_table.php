// database/migrations/xxxx_xx_xx_create_e_tickets_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('e_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('ticket_code')->unique();
            $table->text('qr_code')->nullable();
            $table->dateTime('valid_from');
            $table->dateTime('valid_until');
            $table->boolean('is_used')->default(false);
            $table->dateTime('used_at')->nullable();
            $table->string('check_in_code', 6)->unique();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('e_tickets');
    }
};