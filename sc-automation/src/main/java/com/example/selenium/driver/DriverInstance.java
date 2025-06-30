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

import org.openqa.selenium.support.ui.WebDriverWait;

public class DriverInstance {

    private static WebDriver driver;
    private static WebDriverWait wait;

    private DriverInstance() {
        // Private constructor to prevent instantiation
    }

    //getter method for the driver singleton instance
    public static WebDriver getDriver() throws MalformedURLException, URISyntaxException {
    if (driver == null) {
        ChromeOptions options = new ChromeOptions();
        HashMap<String, Object> prefs = new HashMap<>();
        prefs.put("download.default_directory", "C:\\Users\\qianchen.jiang\\Downloads");
        prefs.put("download.prompt_for_download", false);
        prefs.put("safebrowsing.enabled", true);
        options.setExperimentalOption("prefs", prefs);

        // Check if running in CI
        String runEnv = System.getenv("CI"); // or use a custom ENV like SELENIUM_REMOTE

        if ("true".equalsIgnoreCase(runEnv)) {
            // Running in GitLab CI with remote Selenium
            URL seleniumGridUrl = new URI("http://selenium:4444/wd/hub").toURL();
            driver = new RemoteWebDriver(seleniumGridUrl, options);
        } else {
            // Running locally, use local ChromeDriver
            driver = new ChromeDriver(options); // Assumes chromedriver is in PATH
        }
    }
    return driver;
}

    public static WebDriverWait getWait() {
        if (wait == null && driver != null) {
            wait = new WebDriverWait(driver, Duration.ofSeconds(5));
        }
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