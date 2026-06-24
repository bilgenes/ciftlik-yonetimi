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

    // YENİ EKLENEN GET METODU (Stok Durumu ve Geçmişi Getirir)
    public function index(): JsonResponse
    {
        // 1. İşlem Geçmişi (En yeni 50 işlemi getir)
        $transactions = StockTransaction::orderBy('transaction_date', 'desc')
            ->orderBy('id', 'desc')
            ->take(50)
            ->get();

        // Veritabanı boşsa arayüz tasarımı bozulmasın diye varsayılan veriler döndür
        if ($transactions->isEmpty()) {
            return response()->json([
                'current_stocks' => ['Süt' => 850, 'Yem' => 2500, 'Saman' => 120, 'Silaj' => 5200],
                'transactions' => []
            ]);
        }

        // 2. Güncel Stok Hesaplama (Giren - Çıkan)
        $items = ['süt', 'yem', 'saman', 'silaj'];
        $currentStocks = [];

        foreach ($items as $item) {
            $in = StockTransaction::where('item_name', $item)->where('transaction_type', 'in')->sum('quantity');
            $out = StockTransaction::where('item_name', $item)->where('transaction_type', 'out')->sum('quantity');

            $stock = $in - $out;
            $currentStocks[ucfirst($item)] = $stock > 0 ? $stock : 0; // Negatife düşmesin
        }

        return response()->json([
            'current_stocks' => $currentStocks,
            'transactions' => $transactions
        ]);
    }

    // MEVCUT POST METODU
    public function purchase(Request $request)
    {
        $data = $request->validate([
            'item_name' => 'required|string',
            'quantity' => 'required|numeric|min:0',
            'total_price' => 'required|numeric|min:0',
            'transaction_date' => 'required|date'
        ]);

        $data['item_name'] = strtolower($data['item_name']); // Her zaman küçük harfle kaydet
        $data['transaction_type'] = 'in'; // Alım
        $data['unit_price'] = $data['quantity'] > 0 ? ($data['total_price'] / $data['quantity']) : 0;

        // 1. Stoğa Ekle
        $stock = StockTransaction::create($data);

        // 2. OTOMATİK FİNANSA GİDER YAZ (Sadece maliyet 0'dan büyükse, yani 'Üretim' değilse)
        if ($data['total_price'] > 0) {
            $this->financeService->addTransaction([
                'transaction_type' => 'gider',
                'category' => 'stok_alimi',
                'amount' => $data['total_price'],
                'description' => $data['quantity'] . ' birim ' . $data['item_name'] . ' alımı',
                'transaction_date' => $data['transaction_date']
            ]);
        }

        return response()->json(['message' => 'Stok başarıyla eklendi.', 'transaction' => $stock], 201);
    }
}
