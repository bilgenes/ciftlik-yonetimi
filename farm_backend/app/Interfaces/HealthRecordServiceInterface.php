<?php
namespace App\Interfaces;

use App\Models\HealthRecord;
use Illuminate\Database\Eloquent\Collection;

interface HealthRecordServiceInterface
{
public function getRecordsByCowId(int $cowId): Collection;
public function addRecord(array $data): HealthRecord;
}
