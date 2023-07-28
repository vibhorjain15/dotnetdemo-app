using Xunit;
using ProjectName.Api.Controllers;

namespace ProjectName.Tests
{
    public class HomeControllerTests
    {
        [Fact]
        public void Get_ReturnsExpectedMessage()
        {
            // Arrange
            var controller = new HomeController();

            // Act
            var result = controller.Get();

            // Assert
            Assert.Equal("Hello GR World", result);
        }
    }
}

