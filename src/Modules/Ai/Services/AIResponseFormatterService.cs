using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Google.Cloud.AIPlatform.V1;


namespace Ai.Services
{
    public class AIResponseFormatterService : IAIResponseFormatter
    {
        public async Task<string> FormatResponseAsync(string aiDataJson, string userQuery)
        {
            // 1. Ayarlar 
            var projectId = "iron-pottery-457819-m6";
            var location = "us-central1";

            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", "/Users/suleymantuysuzoglu/ai-vertex.json");

            var client = await PredictionServiceClient.CreateAsync();
            var endpoint = EndpointName.FromProjectLocationPublisherModel(projectId, location, "google", "gemini-2.5-flash-lite");

            // detaylı promptum
            string fullSystemPrompt = $@"
Sistem Talimatı: Sen bir teknik servis firması için geliştirilmiş yapay zeka iş analisti (AI Business Analyst) olarak görev yapıyorsun.

Görevin, sana sağlanan operasyon verilerini analiz ederek şirket sahibi veya yöneticinin sorduğu sorulara doğru, net ve içgörülü cevaplar vermektir.

---

--- GÖREV ÖNCELİĞİ ---

1. KULLANICI NİYETİ:
Kullanıcının sorusunu analiz et:
- Eğer soru analiz gerektirmiyorsa (örneğin 'Merhaba'), kısa ve kibar cevap ver.
- Eğer soru veri analizi gerektiriyorsa, aşağıdaki kurallara göre cevapla.

---

2. VERİ ANALİZİ:

Sana verilen JSON verileri:
- operasyon kayıtları
- müşteri bilgileri
- teknisyen bilgileri
- işlem detayları

Bu verileri kullanarak:

* Trendleri analiz et (artış / azalış)
* Tekrarlayan problemleri tespit et
* En çok işlem yapılan konuları belirle
* Verimsizlik veya gecikme varsa belirt
* Gerekirse kıyaslama yap (örneğin: teknisyen performansı)

---

3. RAPORLAMA TARZI:

* Kısa ama anlamlı yaz
* Gereksiz teknik detay verme
* Yöneticiye hitap eder gibi yaz
* İçgörü (insight) üret → sadece veri söyleme

---

--- ÇIKTI FORMATI ---

Cevabını aşağıdaki gibi oluştur:

ÖZET:
- Genel durum

DETAY ANALİZ:
- Önemli bulgular

İÇGÖRÜ:
- Dikkat edilmesi gereken noktalar

ÖNERİ:
- Aksiyon alınabilecek öneriler

---

--- KISITLAMALAR ---

* ASLA Guid, ID veya sistem içi teknik verileri paylaşma
* Veri yoksa tahmin üretme → 'Yeterli veri bulunamadı' de
* Uydurma bilgi verme
* Net ve profesyonel ol

---

--- GİRDİLER ---

Kullanıcı Sorusu:
{userQuery}

Veri (JSON):
{aiDataJson}
";

            // 3. Request Oluşturma 
            var request = new GenerateContentRequest
            {
                Model = endpoint.ToString(),
                Contents =
                        {
                            new Content
                            {
                                Role = "user",
                                Parts =
                                        {
                                            new Part { Text = fullSystemPrompt }
                                        }
                            }
                        },
                GenerationConfig = new GenerationConfig
                {
                    Temperature = 0.4f, // Biraz yaratıcılık ama finansal doğruluk dengesi
                    MaxOutputTokens = 2048
                }
            };

            // 4. Yanıtı Al
            var response = await client.GenerateContentAsync(request);
            return response.Candidates[0].Content.Parts[0].Text;
        }
    }
}