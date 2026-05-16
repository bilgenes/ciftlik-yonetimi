<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HealthRecord extends Model
{
    protected $guarded = [];

    // Veritabanından çekerken bu alanın otomatik olarak bir Tarih objesi olmasını sağlıyoruz
    protected $casts = [
        'treatment_date' => 'date',
    ];

    // Bu sağlık kaydı hangi ineğe ait (Çoğa-Bir İlişki)
    public function cow(): BelongsTo
    {
        return $this->belongsTo(Cow::class);
    }
}
