teknisyen oluşturulduğunda tenantid neden user modülünden çekiliyor? araştır. "Token servisinde userservice ile çekilmiş tenant bilgisi" [SOLVED] ancak böyle kalacak.
teknisyen op status change edildiğinde ai modülünde embedding title ve description neden gitmiyor kontrol? [SOLVED]

Şuan için müşteri bilgileri ai modülüne sadece customerid olarak gidiyor. ancak info olarak isim soyisim de giderse daha mantıklı. *** [TO-DO]

Teknisyene operation modülünden bakım emri yaratıldığında teknisyenoperations tablosunda operasyon tipi de tutulmalı. **
[SOLVED] [ANCAK AI MODÜLÜNE TYPE HENÜZ GÖNDERMEDİM. GÖNDERİLECEK]



device işlemler fikirleri : 
- müşteri sisteme kayıt - sonra müşterinin device sisteme kayıt. device-müşteri mapping. [SOLVED]
- müşteri sisteme kayıt- müşteriye ürün satışı sonrası garanti periyodu vs tüm device bilgileri ile device kayıt. device müşteri mapping. [STANDBY]

- Device oluşturup müşteriye maplendikten sonra operasyon yaratılacak mı? [AR-GE]
** tercihen device oluşturulup müşteriye maplenirken zaten Status alıyoruz. Status eğer ki inrepair ya da maintenance ise direkt operasyon modülüne event publishlenebilir. [OPERASYON MODÜLÜNDEKİ OPERATION CREATE SERVİSİNE TYPE İLE GİDER] [DEĞİŞME-1] 
** Device ve müşteri yaratıldığında operasyon create işlemini opsiyonel bırakacağım. [DEĞİŞME-2] [OPTIONAL]

 Operation fikir: 
- operation status değiştiğinde aynı şekilde device status da değişmesi lazım.  Ancak deviceda farklı bir status var şuan isim değişikliğine gidilecek. [STANDBY]





 RAPORLAR MODÜLÜ:
- Raporlar modülü sağlam refactor ve review istiyor. [MEDIUM]
- Teknisyen metriklerinde operasyonid gelmiyor [URGENT] [BUG] [SOLVED] operasyonid kayıt işlemi yapılıyor artık.



