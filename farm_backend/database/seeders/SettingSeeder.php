<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Setting;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            // YEM KATSAYILARI
            ['key' => 'dana_yem_katsayisi', 'value' => '3.0', 'description' => 'Danalar normal ineklere göre kaç kat fazla yem yer?'],
            ['key' => 'hamile_yem_katsayisi', 'value' => '0', 'description' => 'Hamile ineklere verilen yem katsayısı (Genelde verilmez)'],

            // SİLAJ KATSAYILARI
            ['key' => 'dana_silaj_katsayisi', 'value' => '3.0', 'description' => 'Danalar normal ineklere göre kaç kat silaj yer?'],
            ['key' => 'hamile_silaj_katsayisi', 'value' => '0.5', 'description' => 'Hamile ineklere verilen silaj katsayısı (Azaltılır)'],

            // SAMAN KATSAYILARI
            ['key' => 'dana_saman_katsayisi', 'value' => '3.0', 'description' => 'Danalar normal ineklere göre kaç kat saman yer?'],
            ['key' => 'hamile_saman_katsayisi', 'value' => '1.5', 'description' => 'Hamile ineklere verilen saman katsayısı (Arttırılır)'],

            // SÜT KURALLARI
            ['key' => 'buzagi_gunluk_sut_lt', 'value' => '5.0', 'description' => 'Bir buzağı günde kaç litre süt tüketir?'],
            ['key' => 'buzagi_sut_kesim_ayi', 'value' => '3', 'description' => 'Buzağılar kaç ay sonra sütten kesilip yeme başlar?'],
            ['key' => 'hamile_sut_kesim_ayi', 'value' => '7', 'description' => 'Hamile inekler kaçıncı aydan sonra sağılmaz?']
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
