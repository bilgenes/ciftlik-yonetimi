<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\DailyLogServiceInterface;
use App\Models\DailyLog;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DailyLogController extends Controller
{
    private DailyLogServiceInterface $dailyLogService;

    public function __construct(DailyLogServiceInterface $dailyLogService)
    {
        $this->dailyLogService = $dailyLogService;
    }

    // 1. Son Girilen Günün Verisini Getir (Kullanıcı unutursa diye)
    public function getLastLog(): JsonResponse
    {
        $lastLog = DailyLog::orderBy('log_date', 'desc')->first();

        if (!$lastLog) {
            return response()->json(['message' => 'Henüz hiç kayıt girilmemiş.'], 404);
        }

        return response()->json($lastLog);
    }

    // 2. Yeni Günlük Veri Ekle
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'log_date' => 'required|date|unique:daily_logs,log_date', // Aynı güne 2 kez girilmesini engeller
            'milk_produced' => 'required|numeric|min:0',
            'feed_consumed' => 'required|numeric|min:0',
            'silage_consumed' => 'required|numeric|min:0',
            'straw_consumed' => 'required|numeric|min:0',
        ]);

        // Veritabanına kaydet
        $log = DailyLog::create($data);

        // Servisi çağırıp o günün tüketim/dağılım raporunu hesapla
        $report = $this->dailyLogService->calculateDailyCosts($data);

        // İleride buraya "Stoktan Düşme" servisini de ekleyeceğiz

        return response()->json([
            'message' => 'Günlük veriler başarıyla kaydedildi.',
            'log' => $log,
            'report' => $report // Mobil uygulamada anında gösterilmesi için raporu da dönüyoruz
        ], 201);
    }
}
