using System.Configuration;

namespace LazyService
{
    internal class AppConfigConfigurationSource : IConfigurationSource
    {
        public AppConfigConfigurationSource()
        {
            ServiceName = ConfigurationManager.AppSettings["ServiceName"];
            ServiceDescription = ConfigurationManager.AppSettings["ServiceDescription"];
        }

        public string ServiceName { get; set; }
        public string ServiceDescription { get; set; }
    }
}