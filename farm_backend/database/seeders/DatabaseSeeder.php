<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Ayarları Veritabanına Bas
        $this->call([
            SettingSeeder::class,
        ]);

        // 2. Test İçin Çiftlik Sahibi Hesabı Oluştur
        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);
    }
}
