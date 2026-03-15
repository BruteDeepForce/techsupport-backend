# TechSupport Mobile

Native Flutter mobil uygulaması bu klasör altında geliştirilecektir.

## Durum

Flutter SDK bu makinede yüklü olmadığı için proje `flutter create` ile otomatik scaffold edilmemiştir.
Yine de başlangıç için gerekli klasör yapısı, `pubspec.yaml` ve temel `lib/` mimarisi hazırlanmıştır.

## Hedef kullanıcılar

- Müşteri
- Saha elemanı / teknisyen

## İlk yaklaşım

- Flutter native UI
- Backend ile REST API üzerinden haberleşme
- JWT tabanlı authentication
- Role bazlı ekran ayrımı

## Önerilen başlangıç yapısı

- `lib/core/` → network, config, theme
- `lib/features/auth/`
- `lib/features/customer/`
- `lib/features/technician/`
- `lib/features/splash/`

## Mevcut başlangıç dosyaları

- `pubspec.yaml`
- `analysis_options.yaml`
- `lib/main.dart`
- `lib/core/config/app_config.dart`
- `lib/core/network/api_client.dart`
- `lib/core/theme/app_theme.dart`
- `lib/features/splash/presentation/splash_page.dart`

## Sonraki adım

Flutter SDK hazır olduğunda bu klasörde uygulama scaffold edilebilir:

```zsh
cd apps/mobile
flutter create .
flutter pub get
flutter run
```

> Not: `flutter create .` bazı dosyaları yeniden oluşturabilir. Mevcut `lib/` yapısını korumak için dikkatli merge etmek gerekir.
