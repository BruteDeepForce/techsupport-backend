using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Accounting.RedisService
{
    public interface IRedisCacheService
    {
        Task<T?> GetAsync<T>(string key, CancellationToken ct = default);
        Task SetAsync<T>(string key, T value, TimeSpan? ttl = null, CancellationToken ct = default);
        Task RemoveAsync(string key, CancellationToken ct = default);
        Task PublishAsync(string channel, string message, CancellationToken ct = default);
    }
}