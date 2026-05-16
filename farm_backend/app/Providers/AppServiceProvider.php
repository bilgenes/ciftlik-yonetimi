<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Interfaces\CowServiceInterface;
use App\Services\CowService;
use App\Interfaces\AuthServiceInterface;
use App\Services\AuthService;
use App\Services\DailyLogService;
use App\Interfaces\DailyLogServiceInterface;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Dependency Injection bağlaması
        $this->app->bind(CowServiceInterface::class, CowService::class);
        $this->app->bind(AuthServiceInterface::class, AuthService::class);
        $this->app->bind(DailyLogServiceInterface::class, DailyLogService::class);
    }

    public function boot(): void
    {
        //
    }
}
