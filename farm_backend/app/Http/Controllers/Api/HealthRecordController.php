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
            'calf_count' => 'nullable|integer|min:1'
        ]);

        // HATA ÇÖZÜMÜ: Sadece sağlık tablosunda olanları ayırıp gönderiyoruz
        $healthData = $request->only(['cow_id', 'type', 'description', 'cost', 'treatment_date']);
        $record = $this->healthService->addRecord($healthData);

        $isBirth = str_contains(mb_strtolower($data['type'], 'UTF-8'), 'doğum') || str_contains(strtolower($data['type']), 'dogum');

        if ($isBirth) {
            $motherCow = Cow::find($data['cow_id']);
            $calfCount = $request->calf_count ?? 1;

            $motherCow->update([
                'category' => 'Süt Veren İnekler',
                'calf_count' => $motherCow->calf_count + $calfCount,
                'pregnancy_start_date' => null
            ]);

            for ($i = 1; $i <= $calfCount; $i++) {
                Cow::create([
                    'tag_number' => 'TR-YENI-' . rand(1000, 9999),
                    'name' => $motherCow->name . ' Yavrusu ' . $i,
                    'birth_date' => $data['treatment_date'],
                    'category' => 'Buzağılar',
                    'mother_id' => $motherCow->id,
                    'status' => 'Aktif'
                ]);
            }
        }

        return response()->json([
            'message' => $isBirth ? "Doğum başarılı, $calfCount adet buzağı eklendi!" : 'Kayıt başarıyla eklendi.',
            'record' => $record
        ], 201);
    }
}
