using Microsoft.AspNetCore.Mvc;

namespace ProjectName.Api.Controllers
{
    [ApiController]
    [Route("/")]
    public class HomeController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            return "Hello GR World";
        }
    }
}

