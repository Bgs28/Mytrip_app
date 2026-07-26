// database/migrations/xxxx_xx_xx_fix_bus_seats_unique_constraint.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Hapus unique constraint lama
        Schema::table('bus_seats', function (Blueprint $table) {
            $table->dropUnique('bus_seats_seat_code_unique');
        });

        // Tambahkan unique constraint baru per bus
        Schema::table('bus_seats', function (Blueprint $table) {
            $table->unique(['bus_id', 'seat_code']);
        });
    }

    public function down(): void
    {
        Schema::table('bus_seats', function (Blueprint $table) {
            $table->dropUnique(['bus_id', 'seat_code']);
            $table->unique('seat_code');
        });
    }
};