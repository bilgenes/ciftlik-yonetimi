<?php
namespace App\Services;

use App\Interfaces\DailyLogServiceInterface;
use App\Models\Cow;
use App\Models\Setting;

class DailyLogService implements DailyLogServiceInterface
{
public function calculateDailyCosts(array $dailyData): array
{
// 1. Tüm Katsayıları Ayarlardan Çek (Veritabanından)
$settings = Setting::pluck('value', 'key');

$danaYemCarp = (float) $settings['dana_yem_katsayisi'];
$hamileYemCarp = (float) $settings['hamile_yem_katsayisi'];

$danaSilajCarp = (float) $settings['dana_silaj_katsayisi'];
$hamileSilajCarp = (float) $settings['hamile_silaj_katsayisi'];

$danaSamanCarp = (float) $settings['dana_saman_katsayisi'];
$hamileSamanCarp = (float) $settings['hamile_saman_katsayisi'];

$buzagiSutTuketimi = (float) $settings['buzagi_gunluk_sut_lt'];

// 2. İnek Sayılarını Kategorilere Göre Al
$sagmalSayisi = Cow::where('category', 'sut_veren')->where('status', 'aktif')->count();
$danaSayisi = Cow::where('category', 'dana')->where('status', 'aktif')->count();
$hamileSayisi = Cow::where('category', 'hamile')->where('status', 'aktif')->count();
$buzagiSayisi = Cow::where('category', 'buzagi')->where('status', 'aktif')->count();

// 3. Süt Hesaplaması (Buzağıların payı düşülüyor)
$toplamBuzagiSutu = $buzagiSayisi * $buzagiSutTuketimi;
$netSut = max(0, $dailyData['milk_produced'] - $toplamBuzagiSutu); // Eksiye düşmemesi için max() kullanıyoruz

// 4. Tüketim Birimlerini Hesapla (Sağmal inek her şeyden 1 birim yer varsayılır)
$toplamYemBirimi = $sagmalSayisi + ($danaSayisi * $danaYemCarp) + ($hamileSayisi * $hamileYemCarp);
$toplamSilajBirimi = $sagmalSayisi + ($danaSayisi * $danaSilajCarp) + ($hamileSayisi * $hamileSilajCarp);
$toplamSamanBirimi = $sagmalSayisi + ($danaSayisi * $danaSamanCarp) + ($hamileSayisi * $hamileSamanCarp);

// 5. Birim Başına Düşen Miktarları Bul (Günlük girilen toplam miktar / Toplam Birim)
$birimYem = $toplamYemBirimi > 0 ? ($dailyData['feed_consumed'] / $toplamYemBirimi) : 0;
$birimSilaj = $toplamSilajBirimi > 0 ? ($dailyData['silage_consumed'] / $toplamSilajBirimi) : 0;
$birimSaman = $toplamSamanBirimi > 0 ? ($dailyData['straw_consumed'] / $toplamSamanBirimi) : 0;

// 6. Raporu Döndür
return [
'sut_raporu' => [
'uretilen_toplam' => $dailyData['milk_produced'],
'buzagilara_giden' => $toplamBuzagiSutu,
'satilabilir_net_sut' => $netSut,
],
'normal_inek_tuketimi' => [
'yem' => $birimYem,
'silaj' => $birimSilaj,
'saman' => $birimSaman,
],
'dana_tuketimi' => [
'yem' => $birimYem * $danaYemCarp,
'silaj' => $birimSilaj * $danaSilajCarp,
'saman' => $birimSaman * $danaSamanCarp,
],
'hamile_inek_tuketimi' => [
'yem' => $birimYem * $hamileYemCarp,
'silaj' => $birimSilaj * $hamileSilajCarp,
'saman' => $birimSaman * $hamileSamanCarp,
]
];
}
}
