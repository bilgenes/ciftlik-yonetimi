<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AgendaEvent;
use App\Models\Goal;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AgendaController extends Controller
{
    // 1. Tüm Takvim Olaylarını Getir
    public function getEvents(): JsonResponse
    {
        $events = AgendaEvent::all();
        return response()->json($events);
    }

    // 2. Takvime Yeni Olay/Not Ekle
    public function storeEvent(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'type'  => 'required|string|in:not,sistem,hedef',
            'date'  => 'required|date',
        ]);

        $event = AgendaEvent::create($data);

        return response()->json($event, 201);
    }

    // 3. Tüm Hedefleri Getir
    public function getGoals(): JsonResponse
    {
        $goals = Goal::all();
        return response()->json($goals);
    }

    // 4. Yeni Hedef Belirle
    public function storeGoal(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title'        => 'required|string|max:255',
            'deadline'     => 'nullable|date',
            'is_completed' => 'boolean',
        ]);

        $data['is_completed'] = $data['is_completed'] ?? false;

        $goal = Goal::create($data);

        return response()->json($goal, 201);
    }

    // 5. Hedefin Tamamlanma Durumunu Değiştir (Checkbox)
    public function toggleGoal(Request $request, $id): JsonResponse
    {
        $goal = Goal::findOrFail($id);

        $request->validate([
            'is_completed' => 'required|boolean',
        ]);

        $goal->is_completed = $request->is_completed;
        $goal->save();

        return response()->json([
            'message' => 'Hedef durumu güncellendi.',
            'goal'    => $goal
        ], 200);
    }
}
