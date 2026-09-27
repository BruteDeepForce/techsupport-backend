using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace TechSupport.Identity.Services;

public interface IPasswordResetEmailSender
{
    Task SendCodeAsync(string recipientEmail, string code, int lifetimeMinutes, CancellationToken ct);
}

public sealed class SmtpPasswordResetEmailSender : IPasswordResetEmailSender
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SmtpPasswordResetEmailSender> _logger;

    public SmtpPasswordResetEmailSender(IConfiguration configuration, ILogger<SmtpPasswordResetEmailSender> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendCodeAsync(string recipientEmail, string code, int lifetimeMinutes, CancellationToken ct)
    {
        var host = _configuration["Smtp:Host"];
        var fromAddress = _configuration["Smtp:FromAddress"];
        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(fromAddress))
        {
            throw new InvalidOperationException("SMTP configuration is missing.");
        }

        var port = _configuration.GetValue<int?>("Smtp:Port") ?? 587;
        var enableSsl = _configuration.GetValue<bool?>("Smtp:EnableSsl") ?? true;
        var username = _configuration["Smtp:Username"];
        var password = _configuration["Smtp:Password"];
        var fromName = _configuration["Smtp:FromName"] ?? "Lineer Destek";

        using var message = new MailMessage
        {
            From = new MailAddress(fromAddress, fromName),
            Subject = "Lineer Destek parola sıfırlama kodu",
            Body = BuildHtmlBody(code, lifetimeMinutes),
            IsBodyHtml = true
        };
        message.To.Add(new MailAddress(recipientEmail));

        using var client = new SmtpClient(host, port)
        {
            EnableSsl = enableSsl,
            UseDefaultCredentials = false,
            Credentials = string.IsNullOrWhiteSpace(username)
                ? CredentialCache.DefaultNetworkCredentials
                : new NetworkCredential(username, password)
        };
        _logger.LogInformation("Sending password reset email to {RecipientEmail}", recipientEmail);
        try
        {
            await client.SendMailAsync(message, ct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send password reset email to {RecipientEmail}", recipientEmail);
            throw;
        }


        // await client.SendMailAsync(message, ct);
    }

    private string BuildHtmlBody(string code, int lifetimeMinutes)
    {
        return $@"
<html>
<body>
    <p>Parola sıfırlama kodunuz: <strong>{code}</strong></p>
    <p>Bu kod {lifetimeMinutes} dakika geçerlidir.</p>
    <p>Bu işlemi siz başlatmadıysanız bu e-postayı dikkate almayın.</p>
</body>
</html>";
    }
}
