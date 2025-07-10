package com.example.selenium.driver;

import java.time.Duration;
import java.util.HashMap;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.net.URISyntaxException;

import io.github.bonigarcia.wdm.WebDriverManager;

import org.openqa.selenium.support.ui.WebDriverWait;

public class DriverInstance {

    private static WebDriver driver;
    private static WebDriverWait wait;

    private DriverInstance() {
        // Private constructor to prevent instantiation
    }

    //getter method for the driver singleton instance
    public static WebDriver getDriver() throws Exception{
        if (driver == null) {
            ChromeOptions options = new ChromeOptions();
            String downloadDir = System.getenv("DOWNLOAD_DIR"); //get download dir of user through env variable defined in gitlab-ci.yml
            HashMap<String, Object> prefs = new HashMap<>();
            if (downloadDir != null && !downloadDir.isEmpty()) {
                prefs.put("download.default_directory", downloadDir);
            } else {
                prefs.put("download.default_directory", System.getProperty("user.home") +"Downloads"); //fallback
            } 
            // prefs.put("download.default_directory", "C:\\Users\\qianchen.jiang\\Downloads");
            prefs.put("download.prompt_for_download", false);
            prefs.put("safebrowsing.enabled", true);
            options.setExperimentalOption("prefs", prefs);

            // Check if running in CI
            String runEnv = System.getenv("CI"); // or use a custom ENV like SELENIUM_REMOTE
            String runUAT = System.getenv("UAT"); // or use a custom ENV like SELENIUM_REMOTE

            if ("true".equalsIgnoreCase(runEnv)) {
                if ("true".equalsIgnoreCase(runUAT)) 
                {
                    String driverPath = System.getProperty("user.dir") + "\\src\\main\\java\\com\\example\\selenium\\driver\\";
                    System.setProperty("webdriver.chrome.driver",driverPath+ "chromedriver_136.exe");
                    driver = new ChromeDriver(options); // Running in GitLab CI with local ChromeDriver
                }
                else 
                {
                    // Running in GitLab CI with remote Selenium
                    URL seleniumGridUrl = new URI("http://selenium:4444/wd/hub").toURL();
                    driver = new RemoteWebDriver(seleniumGridUrl, options);
                }
            } else {
                WebDriverManager.chromedriver().setup(); // Ensure chromedriver is set up; donwloads matching chromedriver if required
                driver = new ChromeDriver(options); // Assumes chromedriver is in PATH
            }
        }
        return driver;
    }

    public static WebDriverWait getWait() {
        // if (wait == null && driver != null) {
        //     wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        // }
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        return wait;
    }

    public static void quitDriver() {
        if (driver != null) {
            driver.quit();
            driver = null; // reset driver
            wait = null; // reset wait
        }
    }
}