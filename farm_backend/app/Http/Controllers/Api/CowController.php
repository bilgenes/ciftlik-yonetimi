<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCowRequest;
use App\Interfaces\CowServiceInterface;
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
        $cow = $this->cowService->createCow($request->validated());

        return response()->json([
            'message' => 'İnek başarıyla eklendi.',
            'cow' => $cow
        ], 201);
    }
}