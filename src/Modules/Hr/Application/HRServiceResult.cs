namespace Modules.HR.Application;

public enum HRServiceErrorType
{
    None = 0,
    Validation = 1,
    NotFound = 2,
    Conflict = 3
}

public sealed record HRServiceResult<T>(bool Succeeded, T? Data, HRServiceErrorType ErrorType, string? Error)
{
    public static HRServiceResult<T> Ok(T data) => new(true, data, HRServiceErrorType.None, null);
    public static HRServiceResult<T> Fail(string error) => new(false, default, HRServiceErrorType.Validation, error);
    public static HRServiceResult<T> NotFound(string error) => new(false, default, HRServiceErrorType.NotFound, error);
    public static HRServiceResult<T> Conflict(string error) => new(false, default, HRServiceErrorType.Conflict, error);
}
