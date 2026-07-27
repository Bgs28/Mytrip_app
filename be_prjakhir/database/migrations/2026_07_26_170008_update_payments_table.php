// database/migrations/xxxx_xx_xx_update_payments_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            // Tambahkan kolom jika belum ada
            if (!Schema::hasColumn('payments', 'payment_method')) {
                $table->enum('payment_method', ['bank_transfer_bca', 'bank_transfer_mandiri', 'bank_transfer_bni', 'ovo', 'gopay'])
                    ->nullable()->after('total_amount');
            }
            if (!Schema::hasColumn('payments', 'proof_of_payment')) {
                $table->string('proof_of_payment')->nullable()->after('status');
            }
            if (!Schema::hasColumn('payments', 'paid_at')) {
                $table->dateTime('paid_at')->nullable()->after('proof_of_payment');
            }
            if (!Schema::hasColumn('payments', 'notes')) {
                $table->text('notes')->nullable()->after('paid_at');
            }
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn(['payment_method', 'proof_of_payment', 'paid_at', 'notes']);
        });
    }
};