<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Services\FirebaseNotificationService;

class CheckStockCommand extends Command
{
    protected $signature = 'app:check-stocks';
    protected $description = 'Check for low stocks and send push notifications.';

    public function handle(FirebaseNotificationService $notificationService)
    {
        $this->info('Checking for low stocks...');
        
        // Mock logic: Assuming there's a stock table. For now, trigger a demo notification.
        $lowStockItems = ['Yem', 'İlaç'];
        
        $users = User::whereNotNull('fcm_token')->get();
        foreach ($users as $user) {
            foreach ($lowStockItems as $item) {
                $title = "Kritik Stok Uyarısı!";
                $body = "{$item} stoğu kritik seviyeye düştü. Lütfen kontrol edin.";
                
                $notificationService->sendNotification($user->fcm_token, $title, $body, ['type' => 'stock_alert']);
                $this->info("Stock alert sent to {$user->email} for {$item}");
            }
        }
        
        $this->info('Stock check completed.');
    }
}
