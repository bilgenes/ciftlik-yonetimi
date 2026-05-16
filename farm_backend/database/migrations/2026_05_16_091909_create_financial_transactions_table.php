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
        Schema::create('financial_transactions', function (Blueprint $table) {
            $table->id();
            $table->enum('transaction_type', ['gelir', 'gider']);
            $table->string('category'); // sut_satisi, inek_kesimi, veteriner, stok_alimi, manuel
            $table->decimal('amount', 12, 2);
            $table->string('description')->nullable(); // Örn: "TR123 nolu ineğin tedavisi"
            $table->date('transaction_date');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_transactions');
    }
};
