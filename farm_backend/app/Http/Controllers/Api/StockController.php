<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StockTransaction;
use App\Interfaces\FinanceServiceInterface;
use Illuminate\Http\Request;

class StockController extends Controller
{
    private FinanceServiceInterface $financeService;

    public function __construct(FinanceServiceInterface $financeService)
    {
        $this->financeService = $financeService;
    }

    public function purchase(Request $request)
    {
        $data = $request->validate([
            'item_name' => 'required|string',
            'quantity' => 'required|numeric|min:0',
            'total_price' => 'required|numeric|min:0',
            'transaction_date' => 'required|date'
        ]);

        $data['transaction_type'] = 'in'; // Alım
        $data['unit_price'] = $data['total_price'] / $data['quantity']; // Birim fiyatı otomatik hesapla

        // 1. Stoğa Ekle
        $stock = StockTransaction::create($data);

        // 2. OTOMATİK FİNANSA GİDER YAZ
        $this->financeService->addTransaction([
            'transaction_type' => 'gider',
            'category' => 'stok_alimi',
            'amount' => $data['total_price'],
            'description' => $data['quantity'] . ' kg ' . $data['item_name'] . ' alımı',
            'transaction_date' => $data['transaction_date']
        ]);

        return response()->json(['message' => 'Stok başarıyla eklendi ve gidere yansıtıldı.']);
    }
}
