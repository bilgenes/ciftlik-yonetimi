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
        Schema::create('stock_transactions', function (Blueprint $table) {
            $table->id();
            $table->string('item_name'); // yem, silaj, saman
            $table->enum('transaction_type', ['in', 'out']); // in: Alım, out: Tüketim
            $table->decimal('quantity', 10, 2); // Alınan/Kullanılan miktar
            $table->decimal('unit_price', 10, 2)->default(0); // Alımlarda birim fiyat
            $table->decimal('total_price', 10, 2)->default(0); // Alımlarda toplam maliyet
            $table->date('transaction_date');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stock_transactions');
    }
};
