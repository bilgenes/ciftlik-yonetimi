<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FarmNotification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotificationController extends Controller
{
    // Tüm bildirimleri getir
    public function index(): JsonResponse
    {
        $notifications = FarmNotification::orderBy('created_at', 'desc')->get();
        return response()->json($notifications);
    }

    // Tek bir bildirimi okundu olarak işaretle
    public function markAsRead($id): JsonResponse
    {
        $notif = FarmNotification::findOrFail($id);
        $notif->update(['is_read' => true]);
        return response()->json(['message' => 'Okundu işaretlendi.']);
    }

    // Tüm bildirimleri okundu yap
    public function markAllAsRead(): JsonResponse
    {
        FarmNotification::where('is_read', false)->update(['is_read' => true]);
        return response()->json(['message' => 'Tümü okundu olarak işaretlendi.']);
    }

    // Firebase Token'ı kaydet (Giriş yapıldığında çalışır)
    public function updateFcmToken(Request $request): JsonResponse
    {
        $request->validate(['fcm_token' => 'required|string']);

        // Kullanıcıya fcm_token'ı kaydet
        $request->user()->update(['fcm_token' => $request->fcm_token]);

        return response()->json(['message' => 'FCM Token başarıyla kaydedildi.']);
    }
}
