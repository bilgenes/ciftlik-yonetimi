<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CowController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthRecordController;
use App\Http\Controllers\Api\DailyLogController;
use App\Http\Controllers\Api\FinanceController;


// Güvenli Rotalar
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // İnekler
    Route::apiResource('cows', CowController::class);

    // Günlük Kayıtlar
    Route::get('daily-logs/last', [DailyLogController::class, 'getLastLog']);
    Route::post('daily-logs', [DailyLogController::class, 'store']);

    // Sağlık Kayıtları
    Route::get('health-records/cow/{cowId}', [HealthRecordController::class, 'getCowRecords']);
    Route::post('health-records', [HealthRecordController::class, 'store']);

    // Stok Alımı
    Route::post('stocks/purchase', [\App\Http\Controllers\Api\StockController::class, 'purchase']);

    // Finans Modülü API Uçları (index ve store metotlarını otomatik açar)
    Route::apiResource('finances', FinanceController::class)->only(['index', 'store']);
});
