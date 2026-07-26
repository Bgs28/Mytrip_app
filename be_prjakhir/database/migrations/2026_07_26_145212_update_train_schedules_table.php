// database/migrations/xxxx_xx_xx_update_train_schedules_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('train_schedules', function (Blueprint $table) {
            // Hapus kolom yang tidak diperlukan
            if (Schema::hasColumn('train_schedules', 'arrival_time')) {
                $table->dropColumn('arrival_time');
            }
            if (!Schema::hasColumn('train_schedules', 'departure_time')) {
                $table->time('departure_time')->after('departure_date');
            }
            
            // Tambahkan kolom baru
            // $table->time('departure_time')->after('departure_date');
            $table->time('arrival_time')->nullable()->after('departure_time');
        });
    }

    public function down(): void
    {
        Schema::table('train_schedules', function (Blueprint $table) {
            $table->time('arrival_time')->nullable();
            $table->dropColumn(['departure_time']);
        });
    }
};