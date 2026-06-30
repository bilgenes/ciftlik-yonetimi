<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\HealthRecordServiceInterface;
use App\Models\Cow;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class HealthRecordController extends Controller
{
    private HealthRecordServiceInterface $healthService;

    public function __construct(HealthRecordServiceInterface $healthService)
    {
        $this->healthService = $healthService;
    }

    public function getCowRecords($cowId): JsonResponse
    {
        $records = $this->healthService->getRecordsByCowId($cowId);
        return response()->json($records);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'cow_id' => 'required|exists:cows,id',
            'type' => 'required|string',
            'description' => 'required|string',
            'cost' => 'required|numeric|min:0',
            'treatment_date' => 'required|date',
        ]);

        $record = $this->healthService->addRecord($data);

        // --- YENİ EKLENEN DOĞUM OTOMASYONU ---
        $isBirth = str_contains(strtolower($data['type']), 'doğum') || str_contains(strtolower($data['type']), 'dogum');

        if ($isBirth) {
            $motherCow = Cow::find($data['cow_id']);

            // Anne artık Süt Veren İnek kategorisine geçti
            $motherCow->update([
                'category' => 'Süt Veren İnekler',
                'calf_count' => $motherCow->calf_count + 1
            ]);

            // Yeni bir buzağı profili oluşturuluyor
            Cow::create([
                'tag_number' => 'YENİ-' . rand(1000, 9999), // Geçici küpe, çiftçi sonra düzenler
                'name' => 'İsimsiz Buzağı',
                'birth_date' => $data['treatment_date'],
                'category' => 'Buzağılar',
                'mother_id' => $motherCow->id,
                'status' => 'Aktif'
            ]);
        }

        return response()->json([
            'message' => $isBirth ? 'Sağlık kaydı eklendi, inek statüsü güncellendi ve buzağı doğdu!' : 'Sağlık kaydı başarıyla eklendi.',
            'record' => $record
        ], 201);
    }
}
