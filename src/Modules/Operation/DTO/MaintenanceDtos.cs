using TechSupport.Operation.Domain.Entities;

namespace TechSupport.Operation.DTO;

public sealed record TaxonomyItemDto(Guid Id, string Name, bool IsActive);

public sealed record CreateTaxonomyItemDto(string Name);
public sealed record UpdateTaxonomyItemDto(string Name, bool IsActive);

public sealed record MaintenanceTemplateChecklistDto(
    Guid Id,
    int SortOrder,
    string Title,
    string? Description,
    bool IsRequired,
    bool IsActive);

public sealed record CreateMaintenanceTemplateChecklistDto(
    int SortOrder,
    string Title,
    string? Description,
    bool IsRequired,
    bool IsActive);

public sealed record MaintenanceTemplateDto(
    Guid Id,
    Guid TenantId,
    Guid? BranchId,
    string Name,
    string? Description,
    bool IsActive,
    Guid? ProductTypeId,
    string? ProductTypeName,
    Guid? BrandId,
    string? BrandName,
    Guid? ClassId,
    string? ClassName,
    IReadOnlyList<MaintenanceTemplateChecklistDto> Checklists,
    DateTimeOffset CreatedAtUtc);

public sealed record CreateMaintenanceTemplateDto(
    string Name,
    string? Description,
    Guid? BranchId,
    Guid? ProductTypeId,
    Guid? BrandId,
    Guid? ClassId,
    bool IsActive,
    List<CreateMaintenanceTemplateChecklistDto> Checklists);

public sealed record UpdateMaintenanceTemplateDto(
    string Name,
    string? Description,
    Guid? BranchId,
    Guid? ProductTypeId,
    Guid? BrandId,
    Guid? ClassId,
    bool IsActive,
    List<CreateMaintenanceTemplateChecklistDto> Checklists);

public sealed record MaintenanceTemplateQueryDto(
    Guid? ProductTypeId,
    Guid? BrandId,
    Guid? ClassId,
    bool? IsActive);
