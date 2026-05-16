<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DailyLog extends Model
{
    protected $guarded = [];
    
    // Tarihe göre sıralama ve filtreleme yaparken işimizi kolaylaştıracak
    protected $casts = [
        'log_date' => 'date',
    ];
}
