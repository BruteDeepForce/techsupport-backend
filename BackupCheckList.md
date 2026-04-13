# PostgreSQL Docker Backup & Restore (Windows + Docker + pgvector)

## 🎯 Amaç

Çalışan PostgreSQL container içindeki veritabanını:

1. Dump almak
2. Ayrı bir container (backup DB) oluşturmak
3. Dump’ı restore etmek

---

## 🧱 1. Mevcut DB’den Backup Alma

```powershell
docker exec -t techsupport_postgres pg_dump -U myappuser -d myappdb > C:\Users\user\backups\myappdb.sql
```

✔ Container içinden dump alır
✔ Host makineye kaydeder

---

## 🧱 2. Backup PostgreSQL Container Oluşturma

```yaml
services:
  postgres:
    image: pgvector/pgvector:0.8.1-pg18-trixie
    container_name: techsupport_postgres
    restart: always
    environment:
      POSTGRES_USER: myappuser
      POSTGRES_PASSWORD: rootpassword
      POSTGRES_DB: myappdb
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql

  postgres_backup:
    image: pgvector/pgvector:0.8.1-pg18-trixie
    container_name: techsupport_postgres_backup
    restart: always
    environment:
      POSTGRES_USER: myappuser
      POSTGRES_PASSWORD: rootpassword
      POSTGRES_DB: backupdb
    ports:
      - "5440:5432"
    volumes:
      - pgdata_backup:/var/lib/postgresql

volumes:
  pgdata:
  pgdata_backup:
```

✔ Ayrı volume kullan (çok kritik)
✔ Aynı volume kullanma (data corruption riski)

---

## 🚀 3. Backup Container Başlatma

```bash
docker compose up -d postgres_backup
```

---

## 🔥 4. Dump’ı Restore Etme (PowerShell)

### ❌ Yanlış (çalışmaz)

```powershell
psql file.sql
```

### ❌ Yanlış (PowerShell < desteklemez)

```powershell
< file.sql
```

### ✅ Doğru

```powershell
type C:\Users\user\backups\myappdb.sql | docker exec -i techsupport_postgres_backup psql -U myappuser -d backupdb
```

✔ PowerShell uyumlu
✔ Pipe ile SQL çalıştırılır

---

## 🧪 5. Test

```powershell
docker exec -it techsupport_postgres_backup psql -U myappuser -d backupdb
```

```sql
\dt
```

✔ Tablolar görünüyorsa restore başarılı

---

## ⚠️ Kritik Bilgiler

### 1. Volume Isolation

* Her DB ayrı volume kullanmalı
* Aynı volume = aynı data

### 2. Postgres 18+ Path

* Mount noktası: `/var/lib/postgresql`
* Data internal olarak `/18/...` altında tutulur

### 3. PowerShell Farkı

* `<` çalışmaz
* `type` veya `Get-Content` kullan

### 4. DB İsmi

* Restore ederken doğru DB adı kullan (`backupdb`)

---

## 🧠 Advanced Notlar (Senior Level)

* Training DB → AI testleri burada yapılmalı
* Prod DB → sadece read/write production
* Backup DB → sandbox ortam

---

## 🎯 Özet

✔ Dump alındı
✔ Ayrı container oluşturuldu
✔ Ayrı volume kullanıldı
✔ Restore başarıyla yapıldı
✔ Test edildi

---

## 🚀 Next Level

* Partial restore (table bazlı)
* Tenant bazlı restore
* pg_dump -Fc + pg_restore
* WAL + PITR
* Read replica setup

---

Bu yapı artık:
👉 Eğitim
👉 Test
👉 AI model denemeleri

için production’a yakın sağlam bir altyapıdır.
