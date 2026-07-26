// database/migrations/xxxx_xx_xx_add_price_to_bus_schedules_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bus_schedules', function (Blueprint $table) {
            if (!Schema::hasColumn('bus_schedules', 'price')) {
                $table->integer('price')->nullable()->after('available_seats');
            }
        });

        Schema::table('train_schedules', function (Blueprint $table) {
            if (!Schema::hasColumn('train_schedules', 'price')) {
                $table->integer('price')->nullable()->after('available_seats');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bus_schedules', function (Blueprint $table) {
            $table->dropColumn('price');
        });

        Schema::table('train_schedules', function (Blueprint $table) {
            $table->dropColumn('price');
        });
    }
};