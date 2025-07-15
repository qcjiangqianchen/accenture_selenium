package com.example.selenium.driver;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.chrome.ChromeOptions;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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

            // Check if running in CI
            String runEnv = System.getenv("CI"); // or use a custom ENV like SELENIUM_REMOTE
            String runUAT = System.getenv("UAT"); // or use a custom ENV like SELENIUM_REMOTE

            if ("true".equalsIgnoreCase(runEnv)) {
                if ("true".equalsIgnoreCase(runUAT)) 
                {
                    String driverPath = System.getProperty("user.dir") + "\\src\\main\\java\\com\\example\\selenium\\driver\\";
                    System.setProperty("webdriver.chrome.driver",driverPath+ "chromedriver_136.exe");
                    driver = createChromeDriver(); // Running in GitLab CI with local ChromeDriver
                }
                else 
                {
                    Map<String, Object> prefs = new HashMap<>();
                    prefs.put("download.default_directory", System.getProperty("user.dir") + "\\Resources\\Downloads");
                    prefs.put("download.prompt_for_download", false);
                    prefs.put("download.directory_upgrade", true);
                    prefs.put("safebrowsing.enabled", true);
                    prefs.put("safebrowsing.disable_download_protection", true);
                    prefs.put("plugins.always_open_pdf_externally", true);

                    ChromeOptions options = new ChromeOptions();
                    options.addArguments("start-maximized", "disable-infobars", "window-size=1920,1080", "--disable-extensions", "--disable-gpu", "--disable-dev-shm-usage", "--no-sandbox", "--disable-cache", "--disable-application-cache", "--disk-cache-size=0");
                    options.addArguments("user-data-dir=" + System.getProperty("user.dir") + "\\Resources\\chrome-profile");
                    options.setExperimentalOption("prefs", prefs);
                    // Running in GitLab CI with remote Selenium
                    URL seleniumGridUrl = new URI("http://selenium:4444/wd/hub").toURL();
                    driver = new RemoteWebDriver(seleniumGridUrl, options);
                }
            } else {
                WebDriverManager.chromedriver().setup(); // Ensure chromedriver is set up; donwloads matching chromedriver if required
                driver = createChromeDriver(); // Assumes chromedriver is in PATH
            }
        }
        createDownloadDirectory();
        driver.manage().window().maximize();
        driver.manage().deleteAllCookies();
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
    private static void createDownloadDirectory() {
        String outputDirectory = System.getProperty("user.dir") + "\\Resources\\Downloads";
        Path directoryPath = Paths.get(outputDirectory);
        if (!Files.exists(directoryPath)) {
            try {
                Files.createDirectories(directoryPath);
                System.out.println("Directory created successfully.");
            } catch (IOException e) {
                System.out.println("Failed to create the directory: " + e.getMessage());
            }
        } else {
            System.out.println("Directory already exists.");
        }
    }
    private static ChromeDriver createChromeDriver() {
        Map<String, Object> prefs = new HashMap<>();
        prefs.put("download.default_directory", System.getProperty("user.dir") + "\\Resources\\Downloads");
        prefs.put("download.prompt_for_download", false);
        prefs.put("download.directory_upgrade", true);
        prefs.put("safebrowsing.enabled", true);
        prefs.put("safebrowsing.disable_download_protection", true);
        prefs.put("plugins.always_open_pdf_externally", true);

        ChromeOptions options = new ChromeOptions();
        options.addArguments("start-maximized", "disable-infobars", "window-size=1920,1080", "--disable-extensions", "--disable-gpu", "--disable-dev-shm-usage", "--no-sandbox", "--disable-cache", "--disable-application-cache", "--disk-cache-size=0");
        options.addArguments("user-data-dir=" + System.getProperty("user.dir") + "\\Resources\\chrome-profile");
        options.setExperimentalOption("prefs", prefs);

        return new ChromeDriver(options);
    }
}