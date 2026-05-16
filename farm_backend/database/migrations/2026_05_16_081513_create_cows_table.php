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
    Schema::create('cows', function (Blueprint $table) {
        $table->id();
        $table->string('name')->nullable(); // İsim (opsiyonel)
        $table->string('tag_number')->unique(); // Küpe Kodu (Çok önemli, kamera okuyacak)
        $table->date('birth_date')->nullable(); // Doğum Tarihi / Yaş hesabı için
        
        // Kategoriler: sut_veren, sut_vermeyen, hamile, dana, buzagi
        $table->string('category')->default('sut_veren'); 
        
        $table->boolean('is_lactating')->default(true); // Süt verme durumu (Doğum yapınca otomatik true olacak)
        $table->foreignId('mother_id')->nullable()->constrained('cows')->nullOnDelete(); // Kimin yavrusu olduğu
        
        // Durumlar: aktif, kesildi, oldu
        $table->string('status')->default('aktif'); 
        $table->text('note')->nullable(); // Ekstra Notlar
        
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cows');
    }
};
