<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    // Tablodaki sütunlarına uygun olarak izinleri veriyoruz
    protected $fillable = ['key', 'value', 'description'];
}
