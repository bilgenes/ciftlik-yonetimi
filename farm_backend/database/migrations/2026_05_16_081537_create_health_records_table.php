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
    Schema::create('health_records', function (Blueprint $table) {
        $table->id();
        $table->foreignId('cow_id')->constrained()->cascadeOnDelete(); // İnek silinirse sağlık geçmişi de silinsin
        
        // İşlem Tipi: tedavi, asi, vitamin
        $table->string('type'); 
        $table->string('description'); // Uygulanan tedavinin detayı
        $table->decimal('cost', 10, 2)->default(0); // Tedavi/Aşı ücreti (Finans kısmına yansıyacak)
        $table->date('treatment_date'); // İşlem tarihi
        
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('health_records');
    }
};
