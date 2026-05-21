<?php
namespace App\Interfaces;

use App\Models\Cow;
use Illuminate\Database\Eloquent\Collection;

interface CowServiceInterface
{
    public function getActiveCows(): Collection;
    public function createCow(array $data): Cow;
    public function getCowByTag(string $tagNumber): ?Cow;
}