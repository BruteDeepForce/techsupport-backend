using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http.Json;
using Microsoft.Build.Framework;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace TechSupport.Accounting.RedisService
{
    public class RedisCacheService : IRedisCacheService
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly IDatabase _db;
        private readonly JsonSerializerOptions _jsonOptions;

        private readonly ILogger<RedisCacheService> _logger;

        public RedisCacheService(IConnectionMultiplexer redis, ILogger<RedisCacheService> logger)
        {
            _redis = redis;
            _db = _redis.GetDatabase();
            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = false
            };
            _logger = logger;
        }
        public async Task<T?> GetAsync<T>(string key, CancellationToken ct = default)
        {
            try
            {
                var value = await _db.StringGetAsync(key);
                if (!value.HasValue) return default;
                return JsonSerializer.Deserialize<T>(value!, _jsonOptions);
            }
            catch
            {
                return default;
            }
        }

        public Task PublishAsync(string channel, string message, CancellationToken ct = default)
        {
            throw new NotImplementedException();
        }

        public async Task RemoveAsync(string key, CancellationToken ct = default)
        {
            try
            {
                await _db.KeyDeleteAsync(key);
            }
            catch(Exception ex)
            {
                _logger.LogWarning(ex, "Can not Remove");
            }     
        }

        public async Task SetAsync<T>(string key, T value, TimeSpan? ttl = null, CancellationToken ct = default)
        {
            try
            {
                var bytes = JsonSerializer.Serialize<T>(value, _jsonOptions);
                await _db.StringSetAsync(key, bytes, ttl);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting cache for key {Key}", key);
            }
        }
    }
}