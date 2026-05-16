<?php
namespace App\Interfaces;

interface DailyLogServiceInterface
{
public function calculateDailyCosts(array $dailyData): array;
}
