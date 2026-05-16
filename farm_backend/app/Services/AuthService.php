<?php
namespace App\Services;

use App\Interfaces\AuthServiceInterface;
use Illuminate\Support\Facades\Auth;

class AuthService implements AuthServiceInterface
{
    public function login(array $credentials): ?string
    {
        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            return $user->createToken('farm-mobile-app')->plainTextToken;
        }
        return null;
    }

    // Yeni eklenen metod
    public function logout(): void
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        // Kullanıcının o an kullandığı token'ı veritabanından sil (iptal et)
        $user->currentAccessToken()->delete();
    }
}
