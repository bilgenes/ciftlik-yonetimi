<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCowRequest;
use App\Interfaces\CowServiceInterface;
use App\Models\Cow;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CowController extends Controller
{
    private CowServiceInterface $cowService;

    // Dependency Injection ile servisi içeri alıyoruz
    public function __construct(CowServiceInterface $cowService)
    {
        $this->cowService = $cowService;
    }

    public function index(): JsonResponse
    {
        $cows = $this->cowService->getActiveCows();

        return response()->json($cows);
    }

    public function store(StoreCowRequest $request): JsonResponse
    {
        // Doğrulanmış veriyi servise pasla
        $validatedData = $request->validated();
        $cow = $this->cowService->createCow($validatedData);

        // YENİ: Eğer annesi seçildiyse, annenin yavru sayısını 1 artır
        if (!empty($validatedData['mother_id'])) {
            $mother = Cow::find($validatedData['mother_id']);
            if ($mother) {
                $mother->increment('calf_count');
            }
        }

        return response()->json([
            'message' => 'İnek başarıyla eklendi.',
            'cow' => $cow
        ], 201);
    }

    // YENİ: GÜNCELLEME METODU (Anne seçimi, Tarih Hatası burada çözüldü)
    public function update(Request $request, $id): JsonResponse
    {
        $cow = Cow::findOrFail($id);
        $cow->update($request->all());

        return response()->json($cow);
    }

    // YENİ: SİLME METODU (Öldü Butonu İçin)
    public function destroy($id): JsonResponse
    {
        Cow::destroy($id);
        return response()->json(['message' => 'Silindi'], 204);
    }

    public function getByTag(string $tag): JsonResponse
    {
        $tag = htmlspecialchars(strip_tags($tag)); // Basic sanitization

        $cow = $this->cowService->getCowByTag($tag);

        if (!$cow) {
            return response()->json(['message' => 'Hayvan bulunamadı.'], 404);
        }

        return response()->json($cow);
    }
}
