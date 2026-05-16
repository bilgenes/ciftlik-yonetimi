<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\HealthRecordServiceInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class HealthRecordController extends Controller
{
    private HealthRecordServiceInterface $healthService;

    public function __construct(HealthRecordServiceInterface $healthService)
    {
        $this->healthService = $healthService;
    }

    // Belirli bir ineğin sağlık geçmişini getir
    public function getCowRecords($cowId): JsonResponse
    {
        $records = $this->healthService->getRecordsByCowId($cowId);
        return response()->json($records);
    }

    // Yeni işlem/tedavi ekle
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'cow_id' => 'required|exists:cows,id',
            'type' => 'required|string', // tedavi, asi, vitamin vb.
            'description' => 'required|string',
            'cost' => 'required|numeric|min:0',
            'treatment_date' => 'required|date',
        ]);

        $record = $this->healthService->addRecord($data);

        return response()->json([
            'message' => 'Sağlık kaydı başarıyla eklendi.',
            'record' => $record
        ], 201);
    }
}
