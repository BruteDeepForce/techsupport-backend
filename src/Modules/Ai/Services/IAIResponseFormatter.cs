using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Ai.Services
{
    public interface IAIResponseFormatter
    {
        Task<string> FormatResponseAsync(string aiDataJson, string userQuery);
        
    }
}