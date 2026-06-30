<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            // Annesi sisteme kayıtlı bir inek olabilir, silinirse null olur (onDelete set null)
            $table->foreignId('mother_id')->nullable()->constrained('cows')->onDelete('set null')->after('category');
        });
    }

    public function down(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            $table->dropForeign(['mother_id']);
            $table->dropColumn('mother_id');
        });
    }
};
