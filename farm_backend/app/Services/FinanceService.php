<?php
namespace App\Services;

use App\Interfaces\FinanceServiceInterface;
use App\Models\FinancialTransaction;
use Illuminate\Database\Eloquent\Collection;

class FinanceService implements FinanceServiceInterface
{
    public function getAllTransactions(): Collection
    {
        return FinancialTransaction::orderBy('transaction_date', 'desc')->get();
    }

    public function addTransaction(array $data)
    {
        return FinancialTransaction::create($data);
    }
}
