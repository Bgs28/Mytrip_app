// database/migrations/xxxx_xx_xx_add_columns_to_hotels_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('hotels', function (Blueprint $table) {
            // Tambahkan kolom jika belum ada
            if (!Schema::hasColumn('hotels', 'phone')) {
                $table->string('phone')->nullable()->after('location');
            }
            if (!Schema::hasColumn('hotels', 'email')) {
                $table->string('email')->nullable()->after('phone');
            }
            if (!Schema::hasColumn('hotels', 'address')) {
                $table->text('address')->nullable()->after('email');
            }
            if (!Schema::hasColumn('hotels', 'check_in_time')) {
                $table->time('check_in_time')->nullable()->default('14:00:00')->after('address');
            }
            if (!Schema::hasColumn('hotels', 'check_out_time')) {
                $table->time('check_out_time')->nullable()->default('12:00:00')->after('check_in_time');
            }
            if (!Schema::hasColumn('hotels', 'facilities')) {
                $table->json('facilities')->nullable()->after('check_out_time');
            }
            if (!Schema::hasColumn('hotels', 'images')) {
                $table->json('images')->nullable()->after('image');
            }
        });
    }

    public function down(): void
    {
        Schema::table('hotels', function (Blueprint $table) {
            $table->dropColumn(['phone', 'email', 'address', 'check_in_time', 'check_out_time', 'facilities', 'images']);
        });
    }
};