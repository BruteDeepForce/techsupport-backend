.NET Deploy Checklist
1. Config ve Environment
appsettings.Development.json içindeki değerlerin production’a taşınmadığını kontrol et
Production’da secret bilgilerin kod içinde olmadığını doğrula
Connection string’ler environment variable / secret manager / vault üzerinden gelsin
ASPNETCORE_ENVIRONMENT=Production doğru mu bak
3rd party API key, JWT secret, SMTP bilgileri production için doğru mu kontrol et
Debug amaçlı açık bırakılmış config var mı bak:
verbose logging
swagger unrestricted access
test endpoints
fake services
mock payment / mock mail
2. Database
Migration’lar hazır mı
Production DB’ye hangi migration’ın uygulanacağı net mi
Seed işlemleri production’da problem çıkarır mı kontrol et
Geri dönüş planın var mı:
backup alındı mı
rollback stratejisi var mı
Destructive migration var mı kontrol et:
column drop
table rename
data type change
Connection pool ayarları uygun mu
Transaction timeout / command timeout production için yeterli mi
3. Logging
Uygulama log üretiyor mu
Log formatı okunabilir mi
Exception detayları loglanıyor mu
Ama PII / hassas veri loglanmıyor mu
Log seviyesi production için uygun mu:
Information
gerekirse Warning
sürekli Debug açık olmasın
CorrelationId / TraceId loglara giriyor mu
Merkezi log toplama varsa test et:
Seq
ELK
Grafana Loki
Cloud logging
4. Error Handling
Global exception middleware var mı
API patladığında stack trace client’a dönmüyor mu
Standart error response formatın var mı
Validation error ile server error ayrışıyor mu
try/catch blokları gerçekten anlamlı yerlerde mi
OperationCanceledException ve timeout senaryoları düzgün ele alınıyor mu
5. Security
HTTPS zorunlu mu
CORS production domain’leriyle sınırlı mı
JWT validation ayarları doğru mu:
issuer
audience
signing key
lifetime
Refresh token mekanizması test edildi mi
[Authorize] eksik endpoint var mı
Admin endpoint’leri ekstra kontrol edildi mi
Rate limiting açık mı
Brute force koruması var mı
File upload varsa:
uzantı kontrolü
mime kontrolü
boyut limiti
Secret değerler loglanmıyor mu
Swagger production’da açık olacaksa auth arkasında mı
6. Performance
Büyük sorgularda Include, Select, AsNoTracking doğru kullanıldı mı
N+1 query var mı kontrol edildi mi
Pagination olmayan ağır liste endpoint’i kaldı mı
Gereksiz memory yükü var mı
Büyük dosya / büyük response senaryosu test edildi mi
Cache gereken yerlere cache eklendi mi:
Redis
memory cache
Timeout değerleri mantıklı mı
HttpClient için HttpClientFactory kullanılıyor mu
Retry policy gerekiyorsa eklendi mi
Circuit breaker ihtiyacı olan dış servisler için plan var mı
7. Background Jobs / Messaging
Hangfire / Quartz / worker service job’ları production config ile çalışıyor mu
RabbitMQ / Kafka / MassTransit varsa:
queue isimleri doğru mu
dead-letter stratejisi var mı
retry policy var mı
idempotency düşünülmüş mü
Consumer aynı mesajı 2 kez alırsa sistem bozuluyor mu kontrol et
Outbox kullanıyorsan çalışıyor mu test et
8. API Readiness
Health check endpoint var mı
Liveness / readiness ayrımı gerekiyorsa yapıldı mı
Swagger / OpenAPI dokümanı güncel mi
Versioning varsa route’lar doğru mu
Geriye dönük uyumluluk bozuldu mu
Request / response contract değiştiyse frontend bilgilendirildi mi
9. Docker / Server
Docker image production build mi
Multi-stage build kullanılıyor mu
Container içinde gereksiz SDK yok mu
Port mapping doğru mu
Volume’ler doğru mu
Restart policy var mı
Resource limiti düşünülmüş mü:
CPU
memory
Timezone ihtiyacı varsa net mi
Reverse proxy ayarları tamam mı:
Nginx
Traefik
Domain ve SSL hazır mı
Sunucuda environment variable’lar tanımlı mı
10. Monitoring
Health check çalışıyor mu
CPU / memory / disk izleniyor mu
DB connection sayısı izleniyor mu
Error rate izleniyor mu
Alert sistemi var mı:
mail
Telegram
Discord
Slack
Uygulama ayağa kalktıktan sonra ilk 10 dakika logları izlenecek mi
11. Test
En kritik endpoint’ler manuel test edildi mi
Login / auth / token refresh test edildi mi
Yetki senaryoları test edildi mi
Edge case’ler test edildi mi
Prod’a en yakın ortamda smoke test yapıldı mı
Dosya upload / download varsa denendi mi
Payment / mail / SMS / notification entegrasyonları tek tek denendi mi
12. Business Risk Kontrolü
Deploy saati doğru seçildi mi
Trafiğin en düşük olduğu zaman mı
Geri alma planı var mı
Bir şey bozulursa kim bakacak belli mi
DB migration sonrası app start sırası net mi
Frontend ve backend deploy sırası belli mi
Breaking change varsa koordinasyon yapıldı mı
13. Deploy Sonrası Hızlı Kontrol
Deploy bitince şunları hemen kontrol et:
uygulama ayağa kalktı mı
login çalışıyor mu
database bağlantısı var mı
1–2 kritik create işlemi çalışıyor mu
loglarda exception yağıyor mu
queue consumer’lar bağlı mı
mail / bildirim / dış servis çağrıları çalışıyor mu
health endpoint 200 dönüyor mu?

[ ] Production config kontrol edildi
[ ] Secretlar env/vault üzerinden geliyor
[ ] ASPNETCORE_ENVIRONMENT=Production
[ ] Connection string doğru
[ ] Migration hazır
[ ] DB backup alındı
[ ] Rollback planı hazır
[ ] Global exception handling aktif
[ ] Loglama production seviyesinde
[ ] Hassas veri loglanmıyor
[ ] HTTPS aktif
[ ] CORS production domainlerine kısıtlı
[ ] JWT ayarları doğru
[ ] Swagger production’da güvenli
[ ] Rate limiting aktif
[ ] Kritik sorgular performans kontrolünden geçti
[ ] HttpClientFactory kullanılıyor
[ ] Retry/circuit breaker gereken yerde var
[ ] Background jobs / consumers kontrol edildi
[ ] Health check endpoint aktif
[ ] Docker/server env doğru
[ ] SSL/domain hazır
[ ] Monitoring ve alert hazır
[ ] Kritik endpointler manuel test edildi
[ ] Login/auth test edildi
[ ] Deploy sonrası smoke test planı hazır