package com.example.selenium.testcases;
import java.time.Duration;
import java.util.*;
 
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;
import com.example.selenium.utils.SeleniumUtils;

import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;


public class TCA1 {

    static Map<String, String> scenarioCodeDict = Map.of(
            "HDP Remarks and Conduct", "04",
            "Personal Qualities", "03",
            "Subject Grade", "02",
            "Subject Remarks", "01",
            "Subject Results", "06"
    );

    static boolean breaker = false;
    static long sleepduration = 1000; // 1 second

    public void run(WebDriver driver, WebDriverWait wait) throws Exception {
        System.out.println("TCA1 START");
        // Run scenarios
        String[] scenarios = {"HDP Remarks and Conduct", "Personal Qualities", "Subject Grade", "Subject Remarks", "Subject Results"};
        String[] lockTypes = {"By Level", "By Class"};

        for (String scenario : scenarios) {
            for (String lock : lockTypes) {
                TCA1_1(scenario, lock, driver, wait);
            }
        }

        System.out.println("All Tests Passed");
        System.out.println("✅ TCA1 END");
    }
    // public static void runTest() {
    //     WebDriver driver = null;
    //     try {
    //         ChromeOptions options = new ChromeOptions();
    //         // options.addArguments("--headless=new");

    //         driver = new ChromeDriver(options);
    //         WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(5));
    //         driver.manage().window().maximize();
    //         driver.get("http://predev.schoolcockpit.local.sc/academic/results-by-subject/SEC1-01");

    //         wait.until(ExpectedConditions.titleContains("MIMS Portal"));

    //         WebElement username = wait.until(ExpectedConditions.elementToBeClickable(By.id("Ecom_User_ID")));
    //         WebElement password = wait.until(ExpectedConditions.elementToBeClickable(By.id("Ecom_Password")));
    //         username.sendKeys("SCU00012@schools.gov.sg");
    //         password.sendKeys("Netiq000!1234");

    //         WebElement loginButton = wait.until(ExpectedConditions.elementToBeClickable(By.id("loginButton2")));
    //         loginButton.click();

    //         handleChromeInsecureFormWarning(driver, wait);

    //         // Run scenarios
    //         String[] scenarios = {"HDP Remarks and Conduct", "Personal Qualities", "Subject Grade", "Subject Remarks", "Subject Results"};
    //         String[] lockTypes = {"By Level", "By Class"};

    //         for (String scenario : scenarios) {
    //             for (String lock : lockTypes) {
    //                 TCA1_1(scenario, lock, driver, wait);
    //             }
    //         }

    //         System.out.println("All Tests Passed");
    //         breaker = true;

    //     } catch (Exception e) {
    //         e.printStackTrace();
    //     } finally {
    //         if (driver != null) driver.quit();
    //     }
    // }

    // public static void handleChromeInsecureFormWarning(WebDriver driver, WebDriverWait wait) {
    //     try {
    //         Thread.sleep(2000);
    //         wait.until(ExpectedConditions.titleContains("Form is not secure"));
    //         WebElement btn = wait.until(ExpectedConditions.elementToBeClickable(By.id("proceed-button")));
    //         ((JavascriptExecutor) driver).executeScript("arguments[0].click();", btn);
    //         System.out.println("Bypassed Chrome insecure form warning.");
    //     } catch (Exception ignored) {}
    // }

    public void TCA1_1(String scenario, String lockSetup, WebDriver driver, WebDriverWait wait) throws Exception {
        SeleniumUtils.navigateToDesiredPage("//li[contains(@class, 'child-module')]//a[contains(normalize-space(), 'Cut-Off')]");
        Thread.sleep(sleepduration);
        System.out.println("Results Cutoff page chosen");

        String scenarioCode = scenarioCodeDict.get(scenario);
        System.out.println("Scenario: " + scenarioCode);
        
        Select scenarioDropdown = new Select(wait.until(ExpectedConditions.elementToBeClickable(
                By.cssSelector("select.custom-select.academicYear"))));
        scenarioDropdown.selectByValue(scenarioCode);
        Thread.sleep(sleepduration); 
        String inputFieldId = "";
        Select lockDropdown = new Select(wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector("select.custom-select[style*='max-width: 100px']"))));
        
        if ("By Level".equals(lockSetup)) {
            lockDropdown.selectByValue("By Level");
            inputFieldId = "cutoffDate_31%7C0_113";
        } else if ("By Class".equals(lockSetup)) {
            lockDropdown.selectByValue("By Class");
            inputFieldId = "cutoffDate_31%7CSEC1-01%7C0_113";
        }
        Thread.sleep(sleepduration);
        String date = String.format("%02d", new Random().nextInt(28) + 1);
        String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
        String month = months[new Random().nextInt(months.length)];
        SeleniumUtils.scrollToElement(By.id(inputFieldId));
        SeleniumUtils.typeText(By.id(inputFieldId), date + " " + month + " 2025");
        System.out.println("Field filled");
        Thread.sleep(sleepduration);
        WebElement saveButton = wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//button[text()='Save']")));
        saveButton.click();

        System.out.println("Saved");
        System.out.println("Test A1 for: " + scenario + " , " + lockSetup + " passed");
    }
}
