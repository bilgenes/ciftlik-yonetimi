<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class AgendaEvent extends Model
{
    protected $fillable = ['title', 'type', 'date'];
}
