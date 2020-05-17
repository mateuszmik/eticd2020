using System;
using log4net;
using Topshelf;

namespace LazyService
{
    internal class Program
    {
        private static void Main(string[] args)
        {

            var log = LogManager.GetLogger(typeof(LazyWorker));
            var configurationSource = new AppConfigConfigurationSource();
            //
            HostFactory.Run(x =>
            {
                x.Service<LazyWorker>(s =>
                {
                    s.ConstructUsing(name => new LazyWorker(log,configurationSource));
                    s.WhenStarted(tc => tc.Start());
                    s.WhenStopped(tc => tc.Stop());
                });
                x.RunAsLocalSystem();
                log.InfoFormat("1 Starting {0} [{1}]",configurationSource.ServiceName,configurationSource.ServiceDescription);
            });
        }
    }
}
