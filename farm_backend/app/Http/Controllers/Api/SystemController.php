<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cow;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

class SystemController extends Controller
{
    public function checkDailyMilk(): JsonResponse
    {
        $lastUpdate = Setting::where('key', 'last_milk_update')->first();
        $today = now()->toDateString();

        // Eğer bugün henüz süt eklenmediyse motoru çalıştır
        if (!$lastUpdate || $lastUpdate->value !== $today) {
            $settings = Setting::pluck('value', 'key')->toArray();
            $cows = Cow::where('status', 'Aktif')->get();

            foreach ($cows as $cow) {
                // Dart tarafındaki Türkçe karakter temizliğinin aynısı
                $search = ['ı', 'ğ', 'ü', 'ş', 'ö', 'ç', ' '];
                $replace = ['i', 'g', 'u', 's', 'o', 'c', '_'];
                $prefix = str_replace($search, $replace, mb_strtolower($cow->category, 'UTF-8'));

                $milkAmount = floatval($settings[$prefix . '_prodMilk'] ?? 0);

                if ($milkAmount > 0) {
                    $cow->increment('total_milk_produced', $milkAmount);
                }
            }

            Setting::updateOrCreate(['key' => 'last_milk_update'], ['value' => $today]);
            return response()->json(['message' => 'Günlük sütler başarıyla eklendi!', 'status' => 'updated']);
        }

        return response()->json(['message' => 'Sütler bugün zaten eklenmiş.', 'status' => 'skipped']);
    }
}
