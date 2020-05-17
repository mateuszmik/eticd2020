using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using NATS.Client;

namespace NotesWeb.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessagesController : ControllerBase
    {
        // GET api/values
        [HttpGet]
        public ActionResult<JsonResult> Get()
        {
            var result = MessagesQueue.GetAll();
            MessagesQueue.Clear();
            Console.WriteLine($"Returning messages: {result.Select(x => x)}");
            return new JsonResult(result);
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public ActionResult<string> Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }


    public static class MessagesQueue
    {
        private static IList<Msg> _listOfMessages = new List<Msg>();

        public static IReadOnlyCollection<string> GetAll() =>
            _listOfMessages
                .Select(x => System.Text.Encoding.Default.GetString(x.Data))
                .ToList();

        public static void Add(Msg msg) =>
            _listOfMessages.Add(msg);

        public static void Clear()
        {
            _listOfMessages = new List<Msg>();
        }
    }
}
