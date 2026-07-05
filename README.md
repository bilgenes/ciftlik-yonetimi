**GELİŞTİRİLME AŞAMASINDA...**

# 🚜 Akıllı Çiftlik Yönetim Sistemi

Bu proje, modern çiftliklerin sürü takibi, sağlık durumları, stok yönetimi ve finansal analizlerini tek bir merkezden, gerçek zamanlı olarak yönetebilmeleri için geliştirilmiş **Full-Stack (Flutter & Laravel)** bir otomasyon sistemidir.

Geleneksel ve manuel veri girişini ortadan kaldırarak; doğum otomasyonları, otomatik maliyet hesaplamaları ve kategori bazlı üretim tahminleri ile çiftlik yöneticilerine akıllı bir asistan deneyimi sunar.

## ✨ Öne Çıkan Özellikler

### 🐄 Sürü Yönetimi (İneklerim)
*   **Detaylı Kimlik Kartları:** Her hayvana özel yaş, kategori (Süt Veren, Düve, Hamile, Buzağı vb.), anne bilgisi ve yavru sayısı takibi.
*   **Akıllı Üretim Tahmini:** Ayarlar modülünden girilen katsayılara göre hayvanların günlük ve ömür boyu ürettiği sütün otomatik hesaplanması.
*   **Yaşam Döngüsü:** Doğum, "Düve Oldu" terfileri, ölüm ve kesim işlemlerinin tek tuşla yönetimi.

### 🏥 Sağlık ve Gebelik Takibi
*   **Gebelik Motoru:** Hamilelik başlangıç tarihi takibi ve "Doğum Yaptı" butonu ile girilen yavru sayısı kadar otomatik yeni buzağı profilinin oluşturulması.
*   **Tedavi ve Aşı Geçmişi:** Uygulanan tedavilerin maliyetleriyle birlikte hayvanın geçmişine işlenmesi.
*   **Kronik Hastalıklar:** İyileşen ve hasta olan hayvanların durum takibi.

### 💰 Finans ve Analiz
*   **Tam Otomasyon:** İnek kesimi, süt satışı veya veteriner tedavisi girildiğinde finans defterine anında gelir/gider olarak yansıması.
*   **Görsel Analizler:** Son 6 aylık gelir-gider trendlerini gösteren dinamik çizgi grafikleri.
*   **Tarihsel Gruplama:** Geçmiş işlemlerin gün gün, tarih bazlı filtrelenerek listelenmesi.

### 📦 Stok Takibi
*   **Üretim ve Tüketim:** Satılan sütün stoktan otomatik düşmesi.
*   **Maliyet Entegrasyonu:** Yem, saman ve silaj alımlarının anında finans defterine gider olarak yazılması.

### ⚙️ Dinamik Ayarlar
*   Çiftlik adı belirleme ve kategori bazında (Süt veren, düve vb.) günlük süt üretim beklentilerini sisteme tanımlama.

---

## 🛠️ Kullanılan Teknolojiler

**Frontend (Mobil Uygulama):**
*   [Flutter](https://flutter.dev/) - Çapraz platform mobil arayüz.
*   [Riverpod](https://riverpod.dev/) - Modern ve güvenli State Management.
*   [Dio](https://pub.dev/packages/dio) - Güçlü HTTP istemcisi ve API iletişimi.

**Backend (REST API):**
*   [Laravel](https://laravel.com/) - PHP tabanlı, sağlam mimarili backend framework.
*   [MySQL / PostgreSQL] - İlişkisel veritabanı yönetimi.
*   Sanctum - API kimlik doğrulama işlemleri (Gelecek güncellemeler için hazır).

---

https://github.com/user-attachments/assets/61cd137c-664b-48d2-a13f-4546cbb873cf

## 👨‍💻 Geliştirici

**Enes Bilge**

"Computer Engineering Student & Junior Backend Developer"

Bu proje geliştirme aşamasındadır ve açık kaynak dünyasına katkı sağlamak, yetenekleri sergilemek amacıyla GitHub'a yüklenmiştir. Kodları incelemekten veya geri bildirimde bulunmaktan çekinmeyin!

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz.

### 1. Backend (Laravel) Kurulumu
```bash
# Depoyu klonlayın
git clone [https://github.com/KULLANICI_ADINIZ/ciftlik-backend.git](https://github.com/KULLANICI_ADINIZ/ciftlik-backend.git)

# Bağımlılıkları yükleyin
composer install

# Ortam değişkenlerini ayarlayın
cp .env.example .env
php artisan key:generate

# Veritabanını oluşturun ve tabloları ekleyin
php artisan migrate

# Sunucuyu başlatın
php artisan serve --host=0.0.0.0 --port=8000

# Depoyu klonlayın
git clone [https://github.com/KULLANICI_ADINIZ/ciftlik-frontend.git](https://github.com/KULLANICI_ADINIZ/ciftlik-frontend.git)

# Bağımlılıkları yükleyin
flutter pub get

# API URL'sini ayarlayın
# lib/core/network/dio_client.dart dosyasındaki baseUrl kısmını yerel IP adresinize göre güncelleyin.

# Uygulamayı çalıştırın
flutter run





