- Login akışı başlatıldı. [COMPLETED]
- api_client.dart - auth_interceptor.dart - auth_Service.dart - token_storage.dart yaratıldı. [COMPLETED]
- apiclient tarafında DIO kullandık ve konfigleri burada yaptık. [COMPLETED]
- authservice direkt olarak apiye çıkış yapan metot. [COMPLETED]
- tokenstorage dönen tokenı storage kayıt.[COMPLETED] 
- authinterceptor ?? [LEARNIT]


- Register akışı başlatıldı. [COMPLETED]

- Admin Dashboard 1.Phase fetch readonly [COMPLETED]

- Teknisyenler readonly fetch edilecek. [COMPLETED]
- Teknisyen ekleme silme CRUD işlemleri başlatılacak.  [COMPLETED] [DELETE HARİÇ] []
- Teknisyenlerin Profil fotoğrafları da upload olmalı. UI için upgrade level [UI]   

[TODOLIST][PHASE-1]
- MÜŞTERİ MODÜLÜNDEN TİCKET AÇILACAK [COMPLETED]
- ADMİN TİCKETI DASHBOARDDA GÖRECEK[COMPLETED]
- APPROVE YA DA REJECT EDECEK. [COMPLETED]
- APPROVE EDECEKSE TEKNİSYENE ATAMAYI YAPACAK[COMPLETED]
- TEKNİSYEN MODÜLÜNDEN İSE KENDİNE ATANAN İŞİ TEKNİSYEN GÖREBİLECEK[COMPLETED]

[TODOLIST][PHASE-2]
- TEKNİSYEN STOCK MODÜLÜNDEN PARÇAYI ÇEKECEK
- BU PARÇALAR İÇİN TEKLİFİ ADMİNE SUNACAK
- ADMİN MODÜLÜNDE ADMİN KENDİNE AÇILAN TEKLİFLERİ GÖRECEK
- APPROVE EDECEĞİ TEKLİFİ ONAYLA DİYECEK.
- ONAYLANAN TEKLİF MÜŞTERİ MODÜLÜNDE İLGİLİ MÜŞTERİ İÇİN GÖRÜNTÜLENEBİLECEK
- MÜŞTERİ GÖRDÜĞÜ TEKLİFİ ONAYLA DERSE HEM ADMİN HEM DE TEKNİSYEN MODÜLÜNDE İLGİLİ İŞ EMRİ AKTİF OLARAK GÖRÜNTÜLENECEK!!

- FLUTTER TARAFLI CI/CD PROBLEMİ VAR. [NORMAL] [PIPELINE] [GITHUB] 


- WEB İÇİN DOKPLOYA DEPLOY WHILE CHANGE WEB SIDE. [CHE]
flutter build web --release
git add -f build/web 
git commit -m "add build" 
git push