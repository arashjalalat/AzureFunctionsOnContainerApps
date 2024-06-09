using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace LocalFunctionProj
{
    public class SampleTrigger
    {
        private readonly ILogger<SampleTrigger> _logger;

        public SampleTrigger(ILogger<SampleTrigger> logger)
        {
            _logger = logger;
        }

        [Function("SampleTrigger")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult("Welcome to Azure Functions Arash!");
        }
    }
}
