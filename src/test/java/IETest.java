import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.net.MalformedURLException;
import java.net.URL;

public class IETest {

  private WebDriver driver;

  @BeforeTest
  public void beforeTest() throws MalformedURLException {
    DesiredCapabilities capabilities = new DesiredCapabilities();
    capabilities.setBrowserName("internet explorer");

    driver = new RemoteWebDriver(new URL("http://localhost:4446/wd/hub"), capabilities);
    driver.get("http://www.google.com");
  }

  @Test
  public void main() {
    // for ie crappyness
    try {
      Alert alert = driver.switchTo().alert();
      alert.accept();
    } catch (Exception e) {
      // ignore
    }

    WebElement element = driver.findElement(By.name("q"));
    element.sendKeys("Cheese!");
    element.submit();

    (new WebDriverWait(driver, 10)).until(new ExpectedCondition<Boolean>() {
      public Boolean apply(WebDriver d) {
        return d.getTitle().toLowerCase().startsWith("cheese!");
      }
    });
  }

  @AfterTest
  public void afterTest() {
    driver.quit();
  }
}
