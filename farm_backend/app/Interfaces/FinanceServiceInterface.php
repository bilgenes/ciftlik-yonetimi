<?php
namespace App\Interfaces;

use Illuminate\Database\Eloquent\Collection;

interface FinanceServiceInterface
{
    public function getAllTransactions(): Collection;
    public function addTransaction(array $data);
}
