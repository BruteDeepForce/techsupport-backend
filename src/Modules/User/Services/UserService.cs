using MassTransit;
using Microsoft.EntityFrameworkCore;
using TechSupport.User.Contracts.Events;
using TechSupport.User.Data;
using TechSupport.User.Domain.Entities;

namespace TechSupport.User.Services;

public interface IUserService
{
    Task<UserProfile> CreateAsync(Guid appUserId, Guid tenantId, Guid? branchId, string email, string role, CancellationToken ct);
    Task<UserProfile?> GetByAppUserIdAsync(Guid appUserId, CancellationToken ct);
}

public class UserService : IUserService
{
    private readonly UserDbContext _db;
    private readonly IBus _bus;

    public UserService(UserDbContext db, IBus bus)
    {
        _db = db;
        _bus = bus;
    }

    public async Task<UserProfile> CreateAsync(Guid appUserId, Guid tenantId, Guid? branchId, string email, string role, CancellationToken ct)
    {
        var exists = await _db.UserProfiles.AnyAsync(x => x.TenantId == tenantId && x.Email == email, ct);
        if (exists) throw new InvalidOperationException("User already exists for tenant");

        var profile = new UserProfile
        {
            Id = Guid.NewGuid(),
            AppUserId = appUserId,
            TenantId = tenantId,
            BranchId = branchId,
            Email = email,
            Role = role
        };

        _db.UserProfiles.Add(profile);
        await _db.SaveChangesAsync(ct);

    await _bus.Publish(new UserCreated(profile.Id, profile.TenantId, profile.BranchId ?? Guid.Empty, profile.Email, profile.Role), ct);

        return profile;
    }

    public Task<UserProfile?> GetByAppUserIdAsync(Guid appUserId, CancellationToken ct)
    {
        return _db.UserProfiles.AsNoTracking().FirstOrDefaultAsync(x => x.AppUserId == appUserId, ct);
    }
}
