<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CowController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthRecordController;
use App\Http\Controllers\Api\DailyLogController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\AgendaController;

// --------------------------------------------------------
// DIŞARIYA AÇIK ROTALAR (Token Gerektirmeyenler)
// --------------------------------------------------------
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);


// --------------------------------------------------------
// GÜVENLİ ROTALAR (Sadece Token ile Girilebilenler)
// --------------------------------------------------------
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // İnekler
    Route::get('cows/by-tag/{tag}', [CowController::class, 'getByTag']);
    Route::apiResource('cows', CowController::class);

    // --- AJANDA VE HEDEFLER ---
    Route::get('agenda/events', [AgendaController::class, 'getEvents']);
    Route::post('agenda/events', [AgendaController::class, 'storeEvent']);
    Route::get('agenda/goals', [AgendaController::class, 'getGoals']);
    Route::post('agenda/goals', [AgendaController::class, 'storeGoal']);
    Route::put('agenda/goals/{id}/toggle', [AgendaController::class, 'toggleGoal']);

    // Günlük Kayıtlar
    Route::get('daily-logs/last', [DailyLogController::class, 'getLastLog']);
    Route::post('daily-logs', [DailyLogController::class, 'store']);

    // Sağlık Kayıtları
    Route::get('health-records/cow/{cowId}', [HealthRecordController::class, 'getCowRecords']);
    Route::post('health-records', [HealthRecordController::class, 'store']);

    // Stok Alımı
    Route::post('stocks/purchase', [StockController::class, 'purchase']);

    // Finans Modülü API Uçları (index ve store metotlarını otomatik açar)
    Route::apiResource('finances', FinanceController::class)->only(['index', 'store']);
});
