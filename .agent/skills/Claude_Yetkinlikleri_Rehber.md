# Tasarımcılar İçin En İyi 6 Claude Yetkinliği

## Yetkinlikler Nedir?

Claude'un tasarım yapma şeklini değiştiren basit eklentiler. Yetkinlikler, Claude'a özel görevleri tekrarlanabilir bir şekilde tamamlamayı öğreten araçlardır. Her yetkinlik kendi klasöründe talimatlar, scriptler ve kaynaklar içerir.

---

## Nasıl Kurulur?

Tüm yetkinlikler tek bir komutla kurulur:

```bash
npx skills add https://github.com/anthropics/skills --skill <yetkinlik-adi>
```

Kurulu yetkinlikleri listelemek için:

```bash
npx skills list
```

---

## 6 Yetkinlik ve Kurulum Komutları

### 1. Ön Yüz Tasarımı (Frontend Design)

Claude, kod yazmadan önce tam bir tasarım düşünme sürecinden geçer. Jenerik "AI slop" görünümünden kurtulup, cesur tipografi, özgün renk paletleri ve yaratıcı layout'larla profesyonel arayüzler üretir.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill frontend-design
```

**Link:** [github.com/anthropics/skills/tree/main/skills/frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design)

---

### 2. Figma'dan Koda (Figma to Code)

Bir Figma URL yapıştır, 1:1 sadakatle üretime hazır kod al. Claude, Figma tasarımlarını birebir koda dönüştürür.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill figma
```

**Link:** [github.com/anthropics/skills](https://github.com/anthropics/skills)

---

### 3. Tema Fabrikası (Theme Factory)

Seçilmiş paletler ve font eşleştirmeleriyle 10 profesyonel tema. Slaytlar, dokümanlar, raporlar ve HTML landing page'lere profesyonel temalar uygular.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill theme-factory
```

**Link:** [github.com/anthropics/skills](https://github.com/anthropics/skills)

---

### 4. Marka Kılavuzu (Brand Guidelines)

Renkleriniz, fontlarınız, boşluklar, ton - Claude'un tüm çıktılarında otomatik olarak uygulanır. Tutarlı marka kimliği için tüm çıktılarda aynı stil standardını korur.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill brand-guidelines
```

**Link:** [github.com/anthropics/skills/tree/main/skills/brand-guidelines](https://github.com/anthropics/skills/tree/main/skills/brand-guidelines)

---

### 5. Canvas Tasarım (Canvas Design)

Görsel posterler ve kompozisyonları PNG/PDF dosyaları olarak oluşturur. Cesur geometri, anıtsal form ve brütalist mekansal bölümlerle gerçek görsel sanat üretir.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill canvas-design
```

**Link:** [github.com/anthropics/skills/tree/main/skills/canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design)

---

### 6. Yetkinlik Oluşturucu (Skill Creator)

Tasarım sisteminiz, marka sesiniz veya iş akışınız için kendi özel yetkinliklerinizi oluşturun. Soru-cevap formatıyla interaktif yetkinlik oluşturma aracı.

**Kurulum:**
```bash
npx skills add https://github.com/anthropics/skills --skill skill-creator
```

**Link:** [github.com/anthropics/skills](https://github.com/anthropics/skills)

---

## Tüm Yetkinlikleri Tek Seferde Kurmak

```bash
npx skills add https://github.com/anthropics/skills --skill frontend-design --skill figma --skill theme-factory --skill brand-guidelines --skill canvas-design --skill skill-creator
```

---

## Faydalı Kaynaklar

- **Anthropic Resmi Yetkinlik Reposu:** [github.com/anthropics/skills](https://github.com/anthropics/skills)
- **Vercel Skills Ekosistemi:** [github.com/vercel-labs/skills](https://github.com/vercel-labs/skills)
- **Awesome Claude Skills:** [github.com/travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills)
- **Claude Code Dokümantasyonu:** [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
- **NPM Skills Paketi:** [npmjs.com/package/skills](https://www.npmjs.com/package/skills)

---

## Popüler Diğer Yetkinlikler

| Yetkinlik | Açıklama | Kurulum |
|-----------|----------|---------|
| context7 | Kütüphane dokümanlarını canlı olarak çeker | `npx skills add upstash/context7` |
| ralph-loop | Uzun süreli otonom kodlama oturumları | `npx skills add anthropics/claude-plugins-official` |
| claude-mem | Oturumlar arası hafıza | `npx skills add anthropics/claude-mem` |
| code-review-agents | Paralel çalışan kod inceleme ajanları | `npx skills add anthropics/skills --skill code-review-agents` |
| loki-mode | Gelişmiş prompt mühendisliği | `npx skills add travisvn/loki-mode` |
| claude-d3js-skill | D3.js ile veri görselleştirme | `npx skills add travisvn/claude-d3js-skill` |
