<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Interfaces\AuthServiceInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    private AuthServiceInterface $authService;

    public function __construct(AuthServiceInterface $authService)
    {
        $this->authService = $authService;
    }

    public function login(Request $request): JsonResponse
    {
        // Basit bir validasyon
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $token = $this->authService->login($credentials);

        if (!$token) {
            return response()->json([
                'message' => 'E-posta veya şifre hatalı.'
            ], 401); // 401 Unauthorized
        }

        return response()->json([
            'message' => 'Giriş başarılı',
            'token' => $token
        ]);
    }
    public function logout(): JsonResponse
    {
        $this->authService->logout();

        return response()->json([
            'message' => 'Başarıyla çıkış yapıldı.'
        ]);
    }

    public function register(\Illuminate\Http\Request $request): \Illuminate\Http\JsonResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6'
        ]);

        $token = $this->authService->register($data);

        return response()->json([
            'message' => 'Kayıt başarılı',
            'token' => $token
        ], 201);
    }
}
