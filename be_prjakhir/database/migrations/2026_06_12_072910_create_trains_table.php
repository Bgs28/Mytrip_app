<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('trains', function (Blueprint $table) {

        $table->id();

        $table->string('train_name');

        $table->string('from');

        $table->string('destination');

        $table->time('departure_time');

        $table->time('arrival_time');

        $table->integer('price');

        $table->integer('seat')->default(0);

        $table->timestamps();

    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trains');
    }
};
