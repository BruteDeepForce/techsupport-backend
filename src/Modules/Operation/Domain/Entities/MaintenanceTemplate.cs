namespace TechSupport.Operation.Domain.Entities;

public sealed class MaintenanceTemplate
{
    public Guid Id { get; set; }

    public Guid TenantId { get; set; }
    public Guid? BranchId { get; set; }

    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    // "Uzmanlık" scope fields (tenant-scoped taxonomy)
    public Guid? ProductTypeId { get; set; }
    public OperationProductType? ProductType { get; set; }
    public string? ProductTypeName { get; set; }

    public Guid? BrandId { get; set; }
    public OperationBrand? Brand { get; set; }
    public string? BrandName { get; set; }

    public Guid? ClassId { get; set; }
    public OperationProductClass? Class { get; set; }
    public string? ClassName { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? UpdatedAtUtc { get; set; }

    public List<MaintenanceTemplateChecklist> Checklists { get; set; } = new();
}

public sealed class MaintenanceTemplateChecklist
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }

    public Guid MaintenanceTemplateId { get; set; }
    public MaintenanceTemplate? MaintenanceTemplate { get; set; }

    public int SortOrder { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }

    public bool IsRequired { get; set; } = true;
    public bool IsActive { get; set; } = true;

    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
}
