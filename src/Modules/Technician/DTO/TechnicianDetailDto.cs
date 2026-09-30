using System;
using System.Collections.Generic;

namespace TechSupport.Technician.DTO
{
    public class TechnicianOperationSummaryDto
    {
        public string Title { get; set; } = string.Empty;
        public string? OperationType { get; set; }
        public string Status { get; set; } = string.Empty;
        public string StatusLabel { get; set; } = string.Empty;
        public DateTimeOffset? AssignedAtUtc { get; set; }
    }

    public class TechnicianDetailDto
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? PictureUrl { get; set; }
        public bool IsActive { get; set; }
        public string StatusLabel { get; set; } = string.Empty;
        public DateTimeOffset? EmploymentStartDate { get; set; }
        public int EmploymentMonths { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public List<string> Specializations { get; set; } = new List<string>();
        public int AssignedOperationCount { get; set; }
        public int CompletedOperationCount { get; set; }
        public int PendingOperationCount { get; set; }
        public int OngoingOperationCount { get; set; }
        public decimal CompletionRate { get; set; }
        public List<TechnicianOperationSummaryDto> RecentOperations { get; set; } = new List<TechnicianOperationSummaryDto>();
    }
}
