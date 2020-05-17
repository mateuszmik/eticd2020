using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using NATS.Client;
using NotesWeb.Controllers;

namespace NotesWeb
{
    public class ConfigurationService
    {

        public static string GetNotificationsEndpoint()
        {
            var notificationsUrl = Environment.GetEnvironmentVariable("DN_NOTIFICATIONS_URL", EnvironmentVariableTarget.Machine) ?? "NOTSET";
            return notificationsUrl;
        }

        public static string GetQueuesEndpoint()
        {
            var notificationsUrl = Environment.GetEnvironmentVariable("DN_QUEUES_ENDPOINT") ?? "nats://mmikolajski2:4222";
            Console.WriteLine("Notification url: " + notificationsUrl);
            return notificationsUrl;
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            //_url = ConfigurationService.GetLocalNotificationsEndpoint();
            var thread = new Thread(QueueSubscriber.SubscribeToQueue);
            thread.Start();
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }


    internal static class QueueSubscriber
    {
        private static readonly string MessageAddress = ConfigurationService.GetQueuesEndpoint();
        private static readonly IConnection Connection = new ConnectionFactory().CreateConnection(MessageAddress);

        public static void SubscribeToQueue()
        {
            try
            {
                Console.WriteLine($"Trying to connect to  {MessageAddress}");
                Console.WriteLine($"Notifications Service Successfully connected to  {MessageAddress}");

                var subscription = Connection.SubscribeAsync("notes");
                subscription.MessageHandler += MessageHandler();
                subscription.Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Unable to connect to queueing server on {MessageAddress}. will continue without it.", ex);
            }
        }

        private static EventHandler<MsgHandlerEventArgs> MessageHandler()
        {
            return (sender, args) =>
            {
                Console.WriteLine($"Received: {args.Message}");
                MessagesQueue.Add(args.Message);
            };
        }
    }
}
