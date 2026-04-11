teknisyen oluşturulduğunda tenantid neden user modülünden çekiliyor? araştır. "Token servisinde userservice ile çekilmiş tenant bilgisi" [SOLVED] ancak böyle kalacak.
teknisyen op status change edildiğinde ai modülünde embedding title ve description neden gitmiyor kontrol? [SOLVED]

Şuan için müşteri bilgileri ai modülüne sadece customerid olarak gidiyor. ancak info olarak isim soyisim de giderse daha mantıklı. *** [TO-DO]

Teknisyene operation modülünden bakım emri yaratıldığında teknisyenoperations tablosunda operasyon tipi de tutulmalı. **
[SOLVED] [ANCAK AI MODÜLÜNE TYPE HENÜZ GÖNDERMEDİM. GÖNDERİLECEK]



device işlemler fikirleri : 
- müşteri sisteme kayıt - sonra müşterinin device sisteme kayıt. device-müşteri mapping. [SOLVED]
- müşteri sisteme kayıt- müşteriye ürün satışı sonrası garanti periyodu vs tüm device bilgileri ile device kayıt. device müşteri mapping. [SOLVED]

- Device oluşturup müşteriye maplendikten sonra operasyon yaratılacak mı? [AR-GE]
** tercihen device oluşturulup müşteriye maplenirken zaten Status alıyoruz. Status eğer ki inrepair ya da maintenance ise direkt operasyon modülüne event publishlenebilir. [OPERASYON MODÜLÜNDEKİ OPERATION CREATE SERVİSİNE TYPE İLE GİDER] [DEĞİŞME-1] 
** Device ve müşteri yaratıldığında operasyon create işlemini opsiyonel bırakacağım. [DEĞİŞME-2] [OPTIONAL]

 Operation fikir: 
- operation status değiştiğinde aynı şekilde device status da değişmesi lazım.  Ancak deviceda farklı bir status var şuan isim değişikliğine gidilecek. [STANDBY]

- Teknisyen oluştururken branch/uzmanlık alanı sistemi getirilecek. [COMPLETED]
- Teknisyen tablosunda profil fotoğrafı bulunduralım. [TODO]
- Teknisyen tablosunda işe başlangıç tarihi verelim. [TODO]



 RAPORLAR MODÜLÜ:
- Raporlar modülü sağlam refactor ve review istiyor. [MEDIUM]
- Teknisyen metriklerinde operasyonid gelmiyor [URGENT] [BUG] [SOLVED] operasyonid kayıt işlemi yapılıyor artık.

- Backend Dokploya deploy işlemleri başlatılacak [INPROCCESS]
- DockerFile Rootda mı olacak ? [ROOTCOMPLETED] [ATROOTLOCATED] 

- teknisyen modülü servisinden startprovisionrequest tarafında sistem şuan işe giriş tarhi ve expert göndermiyor. [COMPLETED]
- startprovision işleminde işe giriş tarihini ve experti isteyelim. [COMPLETED]
- technicianProvisionRequest entity içerisinde biz işe giriş tarihini ve experti gönderelim.[COMPLETED]
- TechnicianProvisionRequest tablosuna bunları da kaydedelim. [ilgi propertyler eklensin][COMPLETED]
- technicianPorvisionRequest tablosuna kayıt için ExpertsTechnicianProvision tablosu oluşturulsun. İlişki kurularak.[COMPLETED]
- Complete geldiğinde zaten corelationid ile provisionrequest tablosundan ilgili 2 prop bilgiyi de çekeriz. [COMPLETED]
- Insert to DB.[COMPLETED]


ACCOUNT MUHASEBE MODÜLÜ
- Account GET işlemlerde Row Version boş dönüyor [URGENT]
-


STOCK MODÜLÜ
- Stock modülünde Row version race condition için lazım. Reserve işlemlerinde.  [VITAL]



- Deploy süreç için tüm modüllerde Database.Migrate() tanımlandı.[COMPLETED] 



[ÖNEMLİ]

- docker build -f DockerFile.backend -t techsupport-backend-local . 
- $ docker run --rm -d --name techsupport-backend -p 8080:8080 --network techsupport-backend_default -e ConnectionStrings__DefaultConnection="Host=postgres;Port=5432;Database=myappdb;Username=myappuser;Password=rootpassword" -e RabbitMq__Host="rabbitmq" techsupport-backend-local

- Get-Content secondBackup.sql | docker exec -i b4421066dfdb psql -U myappuser -d backupdb 
[BackUp]




[TODOLIST][LIST]
- Tedarikçi bilgilerini kaydedeceğiz hangi modül tutsun ?
- Ödeme sistemi nasıl olmalı?
- IK modülü eklenecek
- 
