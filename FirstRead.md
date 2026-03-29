# TechSupport - Modular Monolith (.NET 9)

Modular monolith scaffold for a technical service app.

## Monorepo direction

Bu repo artık backend + mobil uygulamayı aynı kökte barındıracak şekilde ilerliyor.

### Current layout

- `src/` → mevcut .NET backend kaynak kodları
- `apps/mobile/` → native Flutter mobil uygulaması için ayrılan klasör

> Not: Bu aşamada mevcut backend klasör yapısı bozulmamıştır. Risk azaltmak için backend şimdilik `src/` altında bırakıldı. İleride istenirse `apps/backend/` altına taşınabilir.

## Structure

Active modules under `src/Modules` (each module has its own `Api/Controllers` and its own `DbContext`):

- `Identity` + `Identity.Contracts` - authentication/authorization (ASP.NET Identity), multi-tenant master-data (`Tenant`, `Branch`) and Identity-owned integration contracts
- `User` + `User.Contracts` - user/profile bounded-context
- `Device` + `Device.Contracts` - device registry bounded-context

Host:

- `src/TechSupport.Web` - ASP.NET Core Web API host (controllers + Swagger + JWT middleware), references modules and wires DI

Mobile:

- `apps/mobile` - native Flutter mobil uygulaması (müşteri + teknisyen deneyimi hedefleniyor)

## Build & run (macOS, zsh)

```bash
# from workspace root
dotnet --version
dotnet build src/TechSupport.Web
cd src/TechSupport.Web
dotnet run
```

Development profile with launch settings is available for `TechSupport.Web`.

Open Swagger UI at http://localhost:5000/swagger when running in Development.

## Persistence: EF Core + PostgreSQL

- Provider: `Npgsql.EntityFrameworkCore.PostgreSQL`
- Pattern: **single database, schema-per-module**
	- Identity: `identity` schema
	- User: `users` schema
	- Device: `devices` schema

### Migrations strategy (recommended)

We keep migrations **inside each module project** (per bounded-context) to avoid coupling everything to the web host.

Notes:

- Startup project for `dotnet-ef` is the host (`src/TechSupport.Web`) because it owns configuration (connection string, environment).
- Target project (`--project`) is the module that owns the `DbContext`.
- Output folder (`--output-dir`) stays under the module (example: `Data/Migrations`).

Example (Device module):

```bash
dotnet ef migrations add Initial_Device \
	--project src/Modules/Device \
	--startup-project src/TechSupport.Web \
	--context TechSupport.Device.Data.DeviceDbContext \
	--output-dir Data/Migrations

dotnet ef database update \
	--startup-project src/TechSupport.Web \
	--context TechSupport.Device.Data.DeviceDbContext
```

> Prereq: `dotnet-ef` tool must be installed.

## Mobile next step (Flutter)

Flutter SDK hazır olduğunda mobil app klasöründe başlangıç scaffold'ı oluşturulabilir:

```bash
cd apps/mobile
flutter create .
```

Önerilen mobil yaklaşım:

- Native Flutter UI
- Backend ile REST API iletişimi
- JWT authentication
- Role bazlı ekran ayrımı (`customer`, `technician`)
