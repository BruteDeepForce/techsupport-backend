- Birden fazla modül arasında event-driven işlemler için daima corelationid üretip log trace özen gösterilecek.
- Birden fazla modül arasında event-driven işlemler için bussinesKey = idempotencyKey olarak Duplicate önüne geçilmesi sağlanacak. 
(Örneğin CustomerCreateEvent() için 

[IdempotencyKey = $"{tenantId}:{email.ToLowerInvariant()}"]

 Aynı insert gelirse Race-Conditions önüne geçilecektir.
)



Opsiyonel olarak sunulan gelişmiş web modül sayesinde müşteriler cep telefonlarına giden takip numarası ile web siteniz üzerinden cihazların son durumlarını görebilir cihaza yorum yapabilir veya onay durumunda olan bir iş emrine onay verebilirler. Ayrıca müşterileriniz kullanıcı adı şifresiyle girerek servis talebinde bulunabilirler. [MANTIKLI]