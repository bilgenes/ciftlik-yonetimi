<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SettingController extends Controller
{
    // Tüm ayarları getir (Flutter'ın kolay okuyabilmesi için Key-Value dizisi olarak göndeririz)
    public function index(): JsonResponse
    {
        // pluck('value', 'key') fonksiyonu veriyi şu formata çevirir:
        // {"milk_price": "15.50", "profile_name": "Enes"}
        $settings = Setting::pluck('value', 'key');
        return response()->json($settings);
    }

    // Ayarları kaydet veya güncelle
    public function store(Request $request): JsonResponse
    {
        $data = $request->all();

        // Gelen tüm JSON verilerini döngüye sokup varsa günceller, yoksa oluştururuz
        foreach ($data as $key => $value) {
            Setting::updateOrCreate(
                ['key' => $key],
                ['value' => (string) $value] // Migration dosyanda value string olduğu için stringe cast ediyoruz
            );
        }

        return response()->json(['message' => 'Sistem katsayıları başarıyla güncellendi.']);
    }
}
