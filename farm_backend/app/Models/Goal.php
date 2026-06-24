<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Goal extends Model
{
    protected $fillable = ['title', 'deadline', 'is_completed'];

    // JSON'a giderken 0/1 yerine true/false gitmesi için:
    protected $casts = [
        'is_completed' => 'boolean',
    ];
}
