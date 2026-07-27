// database/migrations/xxxx_xx_xx_fix_rooms_unique_constraint.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rooms', function (Blueprint $table) {
            // Hapus unique constraint lama
            if (Schema::hasColumn('rooms', 'room_number')) {
                $table->dropUnique('rooms_room_number_unique');
            }
            
            // Tambahkan unique constraint baru per hotel
            $table->unique(['hotel_id', 'room_number']);
        });
    }

    public function down(): void
    {
        Schema::table('rooms', function (Blueprint $table) {
            $table->dropUnique(['hotel_id', 'room_number']);
            $table->unique('room_number');
        });
    }
};