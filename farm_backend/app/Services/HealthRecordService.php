<?php
namespace App\Services;

use App\Interfaces\HealthRecordServiceInterface;
use App\Models\HealthRecord;
use Illuminate\Database\Eloquent\Collection;
use App\Interfaces\FinanceServiceInterface; // BUNU EKLEDİK

class HealthRecordService implements HealthRecordServiceInterface
{
    private FinanceServiceInterface $financeService;

    // CONSTRUCTOR İLE SERVİSİ İÇERİ ALIYORUZ
    public function __construct(FinanceServiceInterface $financeService)
    {
        $this->financeService = $financeService;
    }

    public function getRecordsByCowId(int $cowId): Collection
    {
        return HealthRecord::where('cow_id', $cowId)->orderBy('treatment_date', 'desc')->get();
    }

    public function addRecord(array $data): HealthRecord
    {
        $record = HealthRecord::create($data);

        if ($record->cost > 0) {
            $this->financeService->addTransaction([
                'transaction_type' => 'gider',
                'category' => 'veteriner',
                'amount' => $record->cost,
                'description' => "İnek ID: {$record->cow_id} - {$record->type} işlemi",
                'transaction_date' => $record->treatment_date
            ]);
        }

        return $record;
    }
}
