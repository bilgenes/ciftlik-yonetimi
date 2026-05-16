<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CowController;
use App\Http\Controllers\Api\AuthController;

// Dışarıya Açık Rota
Route::post('/login', [AuthController::class, 'login']);

// Güvenli Rotalar (Sadece geçerli Token'ı olanlar girebilir)
Route::middleware('auth:sanctum')->group(function () {

    // Çıkış Yapma Rotası (Buraya eklendi)
    Route::post('/logout', [AuthController::class, 'logout']);

    // İnek Yönetimi
    Route::apiResource('cows', CowController::class);

// İleride buraya eklenecekler:
// Route::apiResource('daily-logs', DailyLogController::class);
// Route::apiResource('health-records', HealthRecordController::class);
});
