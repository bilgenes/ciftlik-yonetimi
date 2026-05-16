<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\DailyLogServiceInterface;
use App\Models\DailyLog;
use App\Models\StockTransaction; // İçeri aktarımı ekledik
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DailyLogController extends Controller
{
    private DailyLogServiceInterface $dailyLogService;

    public function __construct(DailyLogServiceInterface $dailyLogService)
    {
        $this->dailyLogService = $dailyLogService;
    }

    public function getLastLog(): JsonResponse
    {
        $lastLog = DailyLog::orderBy('log_date', 'desc')->first();

        if (!$lastLog) {
            return response()->json(['message' => 'Henüz hiç kayıt girilmemiş.'], 404);
        }

        return response()->json($lastLog);
    }

    public function store(Request $request): JsonResponse
    {
        // Yorum satırı yerine gerçek validasyon kurallarını yazdık
        $data = $request->validate([
            'log_date' => 'required|date|unique:daily_logs,log_date',
            'milk_produced' => 'required|numeric|min:0',
            'feed_consumed' => 'required|numeric|min:0',
            'silage_consumed' => 'required|numeric|min:0',
            'straw_consumed' => 'required|numeric|min:0',
        ]);

        $log = DailyLog::create($data);
        $report = $this->dailyLogService->calculateDailyCosts($data);

        // Otomatik Stoktan Düşme kısımlarını daha temiz hale getirdik
        if ($data['feed_consumed'] > 0) {
            StockTransaction::create(['item_name' => 'yem', 'transaction_type' => 'out', 'quantity' => $data['feed_consumed'], 'transaction_date' => $data['log_date']]);
        }
        if ($data['silage_consumed'] > 0) {
            StockTransaction::create(['item_name' => 'silaj', 'transaction_type' => 'out', 'quantity' => $data['silage_consumed'], 'transaction_date' => $data['log_date']]);
        }
        if ($data['straw_consumed'] > 0) {
            StockTransaction::create(['item_name' => 'saman', 'transaction_type' => 'out', 'quantity' => $data['straw_consumed'], 'transaction_date' => $data['log_date']]);
        }

        return response()->json(['message' => 'Veriler kaydedildi, stoktan otomatik düşüldü.', 'report' => $report], 201);
    }
}
