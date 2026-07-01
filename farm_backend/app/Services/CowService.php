<?php
namespace App\Services;

use App\Interfaces\CowServiceInterface;
use App\Models\Cow;
use Illuminate\Database\Eloquent\Collection;

class CowService implements CowServiceInterface
{
    /**
     * Sadece aktif inekleri getirir.
     */
    public function getActiveCows(): Collection
    {
        // İleride burada karmaşık filtreleme mantıkları da eklenebilir
        return Cow::where('status', 'aktif')->get();
    }

    /**
     * Yeni bir inek oluşturur ve özel iş kurallarını uygular.
     */
    public function createCow(array $data): Cow
    {
        $cow = Cow::create($data);

        // Eğer yeni ineğin bir annesi belirtildiyse annenin yavru sayısını artır
        if (!empty($data['mother_id'])) {
            $mother = Cow::find($data['mother_id']);
            if ($mother) {
                $mother->increment('calf_count');
            }
        }

        return $cow;
    }

    /**
     * Küpe numarasına göre ineği bulur.
     */
    public function getCowByTag(string $tagNumber): ?Cow
    {
        return Cow::where('tag_number', $tagNumber)->with(['healthRecords', 'dailyLogs'])->first();
    }
}
