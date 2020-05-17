using System;
using System.Text;
using System.Threading;
using NATS.Client;

namespace ProcessingService
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
            var notificationsUrl = Environment.GetEnvironmentVariable("DN_QUEUES_ENDPOINT") ?? "nats://localhost:4222";
            //var notificationsUrl = Environment.GetEnvironmentVariable("DN_QUEUES_ENDPOINT") ?? "nats://notesqueue:4222";
            return notificationsUrl;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            new ProcessingService().Start();
        }
    }

    public class NotificationsMesasage
    {
        public string Message { get; set; }
        public string MessageType { get; set; }
        public Guid Guid { get; set; }
        public DateTime GeneratedOn { get; set; }

        public NotificationsMesasage()
        {
            Guid = Guid.NewGuid();
            GeneratedOn = DateTime.Now;
        }
    }


    internal class ProcessingService
    {
        public void Start()
        {
            var thread = new Thread(Run);
            thread.Start();
        }

        private static void Run()
        {
            var messageAddress = ConfigurationService.GetQueuesEndpoint();
            Console.WriteLine($"Trying to connect to  {messageAddress}");

            using (var c = new ConnectionFactory().CreateConnection(messageAddress))
            {
                Console.WriteLine($"Processing Service successfully connected to  {messageAddress}");
                while (true)
                {
                    Thread.Sleep(3000);
                    var msg = new Msg("notes")
                    {
                        Data = Encoding.ASCII.GetBytes($"This is a note sent on DURING ETI PRESENTATION{DateTime.Now.ToShortTimeString()}")
                    };

                    c.Publish(msg);
                    Console.WriteLine("Message sent");
                }
            }
        }

        public void Stop() { }
    }
}
