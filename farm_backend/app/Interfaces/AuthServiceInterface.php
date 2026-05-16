<?php
namespace App\Interfaces;

interface AuthServiceInterface
{
    public function login(array $credentials): ?string;
    public function logout(): void; // Yeni eklenen satır

    public function register(array $data): string;
}
