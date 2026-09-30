using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Technician.Contracts.AI
{
    /// <summary>
    /// AI tarafına teknisyen kartı bilgisini taşır. Kullanıcıya gösterilen alanlar içerir; teknik kimlik (Id/Guid) bilinçli olarak taşınmaz.
    /// </summary>
    public sealed record TechnicianInfoResponse(
        string Name,
        string? Email,
        string? PhoneNumber,
        string? PictureUrl,
        string Status,
        List<string> Specializations,
        DateTimeOffset? EmploymentStartDate,
        int AssignedOperationCount,
        int CompletedOperationCount,
        int PendingOperationCount);

    /// <summary>
    /// AI tarafına teknisyenin son işlem özetini taşır.
    /// </summary>
    public sealed record TechnicianOperationSummaryInfoResponse(
        string Title,
        string? OperationType,
        string Status,
        string StatusLabel,
        DateTimeOffset? AssignedAtUtc);

    /// <summary>
    /// AI tarafına tek bir teknisyenin detaylı profil bilgisini taşır.
    /// </summary>
    public sealed record TechnicianDetailInfoResponse(
        string Name,
        string? Email,
        string? PhoneNumber,
        string? PictureUrl,
        string Status,
        List<string> Specializations,
        DateTimeOffset? EmploymentStartDate,
        int EmploymentMonths,
        int AssignedOperationCount,
        int CompletedOperationCount,
        int PendingOperationCount,
        int OngoingOperationCount,
        decimal CompletionRate,
        List<TechnicianOperationSummaryInfoResponse> RecentOperations);
}