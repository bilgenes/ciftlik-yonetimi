<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCowRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Şimdilik herkesin istek atmasına izin veriyoruz
    }

    public function rules(): array
    {
        return [
            'name' => 'nullable|string|max:255',
            'tag_number' => 'required|string|unique:cows,tag_number', // Küpe kodu zorunlu ve benzersiz olmalı
            'birth_date' => 'nullable|date',
            'category' => 'required|string',
            'is_lactating' => 'boolean',
            'mother_id' => 'nullable|exists:cows,id',
            'status' => 'required|string',
            'note' => 'nullable|string',
        ];
    }
}
