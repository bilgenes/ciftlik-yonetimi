<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\FinanceServiceInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class FinanceController extends Controller
{
    private FinanceServiceInterface $financeService;

    public function __construct(FinanceServiceInterface $financeService)
    {
        $this->financeService = $financeService;
    }

    // Tüm finansal hareketleri listele (Gelirler ve Giderler tek akışta)
    public function index(): JsonResponse
    {
        $transactions = $this->financeService->getAllTransactions();
        return response()->json($transactions);
    }

    // Manuel Gelir veya Gider Ekleme
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'transaction_type' => 'required|in:gelir,gider',
            'category' => 'required|string|max:255', // fatura, iscilik, yem_satisi, manuel vb.
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:1000',
            'transaction_date' => 'required|date',
        ]);

        $transaction = $this->financeService->addTransaction($data);

        return response()->json([
            'message' => 'Finansal işlem başarıyla kaydedildi.',
            'transaction' => $transaction
        ], 201);
    }
}
