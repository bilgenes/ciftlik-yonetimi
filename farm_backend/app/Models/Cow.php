<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cow extends Model
{
    // Mass assignment (Toplu veri ataması) kilidini açıyoruz
    protected $guarded = []; 

    // 1. Bir ineğin birden fazla sağlık kaydı olabilir (Bire-Çok İlişki)
    public function healthRecords(): HasMany
    {
        return $this->hasMany(HealthRecord::class);
    }

    // 2. Bu ineğin annesi kim? (Kendi tablosuna referans - Çoğa-Bir İlişki)
    public function mother(): BelongsTo
    {
        return $this->belongsTo(Cow::class, 'mother_id');
    }

    // 3. Bu ineğin yavruları (Kendi tablosuna referans - Bire-Çok İlişki)
    public function calves(): HasMany
    {
        return $this->hasMany(Cow::class, 'mother_id');
    }
}
