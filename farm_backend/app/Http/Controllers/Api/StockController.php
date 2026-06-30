<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StockTransaction;
use App\Interfaces\FinanceServiceInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class StockController extends Controller
{
    private FinanceServiceInterface $financeService;

    public function __construct(FinanceServiceInterface $financeService)
    {
        $this->financeService = $financeService;
    }

    // Stokları Ekrana Getirme Metodu (Bunu eklemeliyiz ki ekran dolsun)
    public function index(): JsonResponse
    {
        $transactions = StockTransaction::orderBy('transaction_date', 'desc')->take(50)->get();

        $items = ['süt', 'yem', 'saman', 'silaj'];
        $currentStocks = [];

        foreach ($items as $item) {
            $in = StockTransaction::where('item_name', $item)->where('transaction_type', 'in')->sum('quantity');
            $out = StockTransaction::where('item_name', $item)->where('transaction_type', 'out')->sum('quantity');
            $currentStocks[ucfirst($item)] = max(0, $in - $out);
        }

        return response()->json([
            'current_stocks' => $currentStocks,
            'transactions' => $transactions
        ]);
    }

    public function purchase(Request $request): JsonResponse
    {
        $data = $request->validate([
            'item_name' => 'required|string',
            'quantity' => 'required|numeric|min:0',
            'total_price' => 'required|numeric|min:0',
            'transaction_date' => 'required|date'
        ]);

        $data['item_name'] = strtolower($data['item_name']);
        $data['transaction_type'] = 'in';
        $data['unit_price'] = $data['quantity'] > 0 ? ($data['total_price'] / $data['quantity']) : 0;

        // 1. Stoğa Ekle
        $stock = StockTransaction::create($data);

        // 2. OTOMATİK FİNANSA GİDER YAZ (Sadece Alım ise, yani maliyet 0'dan büyükse)
        if ($data['total_price'] > 0) {
            $unit = $data['item_name'] == 'saman' ? 'balya' : 'kg/litre';
            $this->financeService->addTransaction([
                'transaction_type' => 'gider',
                'category' => 'stok_alimi',
                'amount' => $data['total_price'],
                'description' => $data['quantity'] . ' ' . $unit . ' ' . ucfirst($data['item_name']) . ' alımı',
                'transaction_date' => $data['transaction_date']
            ]);
        }

        return response()->json(['message' => 'Stok eklendi ve finansa yansıtıldı.', 'transaction' => $stock], 201);
    }
}
