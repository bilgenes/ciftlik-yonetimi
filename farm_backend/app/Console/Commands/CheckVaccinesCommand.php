<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Cow;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class CheckVaccinesCommand extends Command
{
    protected $signature = 'app:check-vaccines';
    protected $description = 'Check for cows that need vaccines soon and send push notifications.';

    public function handle(FirebaseNotificationService $notificationService)
    {
        $this->info('Checking for upcoming vaccines...');
        
        // This is a simplified check. Ideally, you have a vaccine schedule table.
        // Let's assume we check health_records or just a mock condition for now.
        $cowsNeedingVaccine = Cow::where('status', 'aktif')->get();
        
        // Mock logic: randomly select one cow for demo if there's any
        if ($cowsNeedingVaccine->isNotEmpty()) {
            $cow = $cowsNeedingVaccine->first();
            
            $users = User::whereNotNull('fcm_token')->get();
            foreach ($users as $user) {
                $title = "Aşı Hatırlatması!";
                $body = "Küpe No: {$cow->tag_number} olan ineğin aşı vakti yaklaşıyor.";
                
                $success = $notificationService->sendNotification($user->fcm_token, $title, $body, ['cow_id' => $cow->id]);
                if ($success) {
                    $this->info("Notification sent to {$user->email}");
                }
            }
        }
        
        $this->info('Vaccine check completed.');
    }
}
