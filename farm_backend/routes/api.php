<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CowController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthRecordController;
use App\Http\Controllers\Api\DailyLogController;


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
});
