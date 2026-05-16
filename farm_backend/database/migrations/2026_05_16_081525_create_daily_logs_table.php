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
    Schema::create('daily_logs', function (Blueprint $table) {
        $table->id();
        $table->date('log_date')->unique(); // Her güne bir kayıt girilecek
        
        // Miktarlar (Ondalıklı değerler girebilmek için decimal kullanıyoruz)
        $table->decimal('milk_produced', 8, 2)->default(0); // Günlük üretilen süt
        $table->decimal('feed_consumed', 8, 2)->default(0); // Günlük kullanılan yem
        $table->decimal('silage_consumed', 8, 2)->default(0); // Günlük kullanılan silaj
        $table->decimal('straw_consumed', 8, 2)->default(0); // Günlük kullanılan saman
        
        $table->timestamps();
    });
}
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('daily_logs');
    }
};
