package com.example.selenium;

import com.example.selenium.login.LoginUtils;
import com.example.selenium.testcases.TCA1;
import com.example.selenium.testcases.TCA5;
import com.example.selenium.testcases.TCA7;
import com.example.selenium.testcases.TCA11;
import com.example.selenium.testcases.TCA13;
import com.example.selenium.testcases.TCA14;
import com.example.selenium.testcases.TCA15;
import com.example.selenium.testcases.TCA16;

import org.testng.annotations.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.*;
import java.time.Duration;

public class TCTest {

    private WebDriver setupDriver() {
        EdgeOptions options = new EdgeOptions();
        HashMap<String, Object> prefs = new HashMap<>();
        prefs.put("download.default_directory", "C:\\Users\\qianchen.jiang\\Downloads");
        prefs.put("download.prompt_for_download", false);
        prefs.put("safebrowsing.enabled", true);
        options.setExperimentalOption("prefs", prefs);
        return new EdgeDriver(options);
    }

    private void prepareEnvironment(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        // Landing page + login
        driver.manage().window().maximize();   //Mazimize current window
        driver.get("http://predev.schoolcockpit.local.sc/academic/results-by-subject/SEC1-01");
        LoginUtils.Login(driver, wait);
        LoginUtils.warningBypass(driver, wait);
    }

    @Test(groups = {"tca1"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA1() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA1.run(driver, wait);
        } finally {
            driver.quit();
        }
    }
    @Test(groups = {"tca7"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA7() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA7.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }
    @Test(groups = {"tca5"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA5() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA5.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }
    @Test(groups = {"tca11"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA11() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA11.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }

    @Test(groups = {"tca13"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA13() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA13.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca14"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA14() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA14.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca15"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA15() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA15.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca16"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA16() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA16.run(driver, wait);
        } finally {
            driver.quit();
        }
    }
}
