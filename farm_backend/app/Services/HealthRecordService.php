<?php
namespace App\Services;

use App\Interfaces\HealthRecordServiceInterface;
use App\Models\HealthRecord;
use Illuminate\Database\Eloquent\Collection;

class HealthRecordService implements HealthRecordServiceInterface
{
public function getRecordsByCowId(int $cowId): Collection
{
// Tarihe göre en yeniden en eskiye sıralayarak getirir
return HealthRecord::where('cow_id', $cowId)->orderBy('treatment_date', 'desc')->get();
}

public function addRecord(array $data): HealthRecord
{
// İleride burada "Eklenen masrafı otomatik Finans modülüne gider yaz" mantığını çalıştıracağız
return HealthRecord::create($data);
}
}
