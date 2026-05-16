<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Setting;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            [
                'key' => 'dana_yem_katsayisi',
                'value' => '3.0',
                'description' => 'Danalar normal ineklere göre kaç kat fazla yem yer?'
            ],
            [
                'key' => 'buzagi_gunluk_sut_lt',
                'value' => '5.0',
                'description' => 'Bir buzağı günde kaç litre süt tüketir?'
            ],
            [
                'key' => 'buzagi_sut_kesim_ayi',
                'value' => '3',
                'description' => 'Buzağılar kaç ay sonra sütten kesilip yeme başlar?'
            ],
            [
                'key' => 'hamile_sut_kesim_ayi',
                'value' => '7',
                'description' => 'Hamile inekler kaçıncı aydan sonra sağılmaz (sütten kesilir)?'
            ]
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
