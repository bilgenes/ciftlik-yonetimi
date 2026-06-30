<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\FinanceServiceInterface;
use App\Models\StockTransaction;
use App\Models\Cow;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class FinanceController extends Controller
{
    private FinanceServiceInterface $financeService;

    public function __construct(FinanceServiceInterface $financeService)
    {
        $this->financeService = $financeService;
    }

    public function index(): JsonResponse
    {
        $transactions = $this->financeService->getAllTransactions();
        return response()->json($transactions);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'transaction_type' => 'required|in:gelir,gider',
            'category' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:1000',
            'transaction_date' => 'required|date',
        ]);

        $transaction = $this->financeService->addTransaction($data);
        return response()->json(['message' => 'Finansal işlem başarıyla kaydedildi.', 'transaction' => $transaction], 201);
    }

    // --- YENİ: SÜT SATIŞI (Stoktan düşer, Finansa ekler) ---
    public function milkSale(Request $request): JsonResponse
    {
        $request->validate([
            'liters' => 'required|numeric|min:1',
            'price' => 'required|numeric|min:0'
        ]);

        // 1. Finansa Gelir Ekle
        $transaction = $this->financeService->addTransaction([
            'transaction_type' => 'gelir',
            'category' => 'Süt Satışı',
            'amount' => $request->price,
            'description' => $request->liters . ' Litre Süt Satışı',
            'transaction_date' => now()
        ]);

        // 2. Stoklardan Sütü Düş (Çıkış İşlemi)
        StockTransaction::create([
            'item_name' => 'süt',
            'transaction_type' => 'out',
            'quantity' => $request->liters,
            'total_price' => $request->price,
            'unit_price' => $request->price / $request->liters,
            'transaction_date' => now()
        ]);

        return response()->json(['message' => 'Süt satıldı, stok güncellendi.', 'transaction' => $transaction], 201);
    }

    // --- YENİ: İNEK KESİMİ (İneği 'Ayrıldı' yapar, Finansa ekler) ---
    public function slaughterCow(Request $request): JsonResponse
    {
        $request->validate([
            'cow_id' => 'required|exists:cows,id',
            'tag_number' => 'required|string',
            'price' => 'required|numeric|min:0'
        ]);

        // 1. İneğin Durumunu Güncelle
        Cow::where('id', $request->cow_id)->update(['status' => 'Ayrıldı']);

        // 2. Finansa Gelir Ekle
        $transaction = $this->financeService->addTransaction([
            'transaction_type' => 'gelir',
            'category' => 'Hayvan Kesimi',
            'amount' => $request->price,
            'description' => $request->tag_number . ' Küpeli Hayvan Kesimi',
            'transaction_date' => now()
        ]);

        return response()->json(['message' => 'İnek kesildi ve gelir eklendi.', 'transaction' => $transaction], 201);
    }
}
