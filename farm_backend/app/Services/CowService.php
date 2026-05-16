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
        // Burada ileride ekleyeceğin "otomatik laktasyon başlatma" 
        // veya "maliyet hesaplama" gibi iş kuralları (Business Logic) yer alacak.
        
        return Cow::create($data);
    }
}