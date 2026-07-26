// database/migrations/xxxx_xx_xx_update_buses_table_add_departure_times.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('buses', function (Blueprint $table) {
            // Hapus kolom yang tidak diperlukan
            if (Schema::hasColumn('buses', 'departure_time')) {
                $table->dropColumn('departure_time');
            }
            
            // Tambahkan kolom baru
            $table->json('departure_times')->nullable()->after('destination'); // ["07:00", "11:00", "15:00", "17:00"]
            $table->integer('duration_minutes')->default(120)->after('departure_times');
            $table->date('start_date')->nullable()->after('duration_minutes');
            $table->date('end_date')->nullable()->after('start_date');
            $table->enum('status', ['active', 'inactive'])->default('active')->after('seat');
        });
    }

    public function down(): void
    {
        Schema::table('buses', function (Blueprint $table) {
            $table->time('departure_time')->nullable();
            $table->dropColumn(['departure_times', 'duration_minutes', 'start_date', 'end_date', 'status']);
        });
    }
};