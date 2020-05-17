namespace LazyService
{
    public interface IConfigurationSource
    {
        string ServiceName { get; }
        string ServiceDescription { get; set; }
    }
}