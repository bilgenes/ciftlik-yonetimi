<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cow extends Model
{
    protected $fillable = [
        'tag_number', 'name', 'birth_date', 'category', 'mother_id', // <-- mother_id EKLENDİ
        'chronic_disease', 'calf_count', 'medical_history',
        'total_milk_produced', 'total_income', 'total_cost',
        'notes', 'status'
    ];

    protected $casts = [
        'birth_date' => 'date',
    ];

    // İneğin annesi ile olan ilişkisi
    public function mother()
    {
        return $this->belongsTo(Cow::class, 'mother_id');
    }

    public function healthRecords()
    {
        return $this->hasMany(HealthRecord::class);
    }

    public function dailyLogs()
    {
        return $this->hasMany(DailyLog::class);
    }
}
