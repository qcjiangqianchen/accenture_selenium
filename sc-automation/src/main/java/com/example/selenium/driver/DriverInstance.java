package com.example.selenium.driver;

import java.time.Duration;
import java.util.HashMap;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class DriverInstance {

    private static WebDriver driver;
    private static WebDriverWait wait;

    private DriverInstance() {
        // Private constructor to prevent instantiation
    }

    //getter method for the driver singleton instance
    public static WebDriver getDriver() {
        if (driver == null) {
            EdgeOptions options = new EdgeOptions();
            HashMap<String, Object> prefs = new HashMap<>();
            prefs.put("download.default_directory", "C:\\Users\\qianchen.jiang\\Downloads");
            prefs.put("download.prompt_for_download", false);
            prefs.put("safebrowsing.enabled", true);
            options.setExperimentalOption("prefs", prefs);

            driver = new EdgeDriver(options);
        }
        return driver;
    }

    public static WebDriverWait getWait() {
        if (wait == null && driver != null) {
            wait = new WebDriverWait(driver, Duration.ofSeconds(15));
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