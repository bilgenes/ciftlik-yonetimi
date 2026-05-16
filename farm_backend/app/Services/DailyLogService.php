<?php
namespace App\Services;

use App\Interfaces\DailyLogServiceInterface;
use App\Models\Cow;
use App\Models\Setting;

class DailyLogService implements DailyLogServiceInterface
{
public function calculateDailyCosts(array $dailyData): array
{
// 1. Ayarları Veritabanından Çek (Artık dinamik okuyoruz)
$danaYemCarpani = (float) Setting::where('key', 'dana_yem_katsayisi')->value('value');
$buzagiSutTuketimi = (float) Setting::where('key', 'buzagi_gunluk_sut_lt')->value('value');

// 2. İnek Sayılarını Kategorilere Göre Al
$sagmalSayisi = Cow::where('category', 'sut_veren')->where('status', 'aktif')->count();
$danaSayisi = Cow::where('category', 'dana')->where('status', 'aktif')->count();
$buzagiSayisi = Cow::where('category', 'buzagi')->where('status', 'aktif')->count();

// 3. Buzağıların içtiği sütü, üretilen toplam sütten düş (Gerçek net süt)
$toplamBuzagiSutu = $buzagiSayisi * $buzagiSutTuketimi;
$netSut = $dailyData['milk_produced'] - $toplamBuzagiSutu;

// 4. Yem Tüketimi Dağılımı Hesaplama (Algoritma)
// Normal inek 1 birim, dana 3 birim (ayar dosyasından gelen değer) yiyor sayarsak:
$toplamYemBirimi = $sagmalSayisi + ($danaSayisi * $danaYemCarpani);

// Gelen toplam yemi birimlere bölerek maliyet hesaplaması için zemin hazırlıyoruz
$birimBasinaYem = $toplamYemBirimi > 0 ? ($dailyData['feed_consumed'] / $toplamYemBirimi) : 0;

return [
'net_satilabilir_sut' => $netSut,
'buzagilarin_ictigi_sut' => $toplamBuzagiSutu,
'normal_inek_yem_maliyeti' => $birimBasinaYem,
'dana_basina_yem_maliyeti' => $birimBasinaYem * $danaYemCarpani
];
}
}
