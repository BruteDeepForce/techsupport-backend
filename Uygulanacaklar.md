- Birden fazla modül arasında event-driven işlemler için daima corelationid üretip log trace özen gösterilecek.
- Birden fazla modül arasında event-driven işlemler için bussinesKey = idempotencyKey olarak Duplicate önüne geçilmesi sağlanacak. 
(Örneğin CustomerCreateEvent() için 

[IdempotencyKey = $"{tenantId}:{email.ToLowerInvariant()}"]

 Aynı insert gelirse Race-Conditions önüne geçilecektir.
)