using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TechSupport.Trade.Services
{
    public sealed record TradeServiceResult<T> 
    {
        public bool Success { get; set; }
        public string ErrorMessage { get; set; }
        public T Data { get; set; }

        public static TradeServiceResult<T> SuccessResult(T data) => new TradeServiceResult<T> { Success = true, Data = data };

        public static TradeServiceResult<T> Failure(string errorMessage) => new TradeServiceResult<T> { Success = false, ErrorMessage = errorMessage };
        
    }
}