<?php

namespace App\Providers;

use App\Interfaces\FinanceServiceInterface;
use App\Services\FinanceService;
use Illuminate\Support\ServiceProvider;
use App\Interfaces\CowServiceInterface;
use App\Services\CowService;
use App\Interfaces\AuthServiceInterface;
use App\Services\AuthService;
use App\Services\DailyLogService;
use App\Interfaces\DailyLogServiceInterface;
use App\Interfaces\HealthRecordServiceInterface;
use App\Services\HealthRecordService;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Dependency Injection bağlaması
        $this->app->bind(CowServiceInterface::class, CowService::class);
        $this->app->bind(AuthServiceInterface::class, AuthService::class);
        $this->app->bind(DailyLogServiceInterface::class, DailyLogService::class);
        $this->app->bind(HealthRecordServiceInterface::class, HealthRecordService::class);
        $this->app->bind(FinanceServiceInterface::class, FinanceService::class);
    }

    public function boot(): void
    {
        //
    }
}
