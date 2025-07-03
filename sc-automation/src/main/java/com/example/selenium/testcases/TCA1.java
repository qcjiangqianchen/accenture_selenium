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
    public void TCA1_1(String scenario, String lockSetup, WebDriver driver, WebDriverWait wait) throws Exception {
        SeleniumUtils.navigateToDesiredPage("//li[contains(@class, 'child-module')]//a[contains(normalize-space(), 'Cut-Off')]");
        System.out.println("Results Cutoff page chosen");

        String scenarioCode = scenarioCodeDict.get(scenario);
        System.out.println("Scenario: " + scenarioCode);
        SeleniumUtils.waitForElementToBeVisible(By.cssSelector("select.custom-select.academicYear"));
        SeleniumUtils.selectDropdownByValue(By.cssSelector("select.custom-select.academicYear"), scenarioCode);
        SeleniumUtils.waitForElementToBeVisible(By.cssSelector("select.custom-select[style*='max-width: 100px']"));
        SeleniumUtils.selectDropdownByValue(By.cssSelector("select.custom-select[style*='max-width: 100px']"), lockSetup);
        String inputFieldId = "";
        if ("By Level".equals(lockSetup)) {
            inputFieldId = "cutoffDate_31%7C0_113";
        } else if ("By Class".equals(lockSetup)) {
            inputFieldId = "cutoffDate_31%7CSEC1-01%7C0_113";
        }
        String date = String.format("%02d", new Random().nextInt(28) + 1);
        String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
        String month = months[new Random().nextInt(months.length)];
        SeleniumUtils.waitForElementToBeVisible(By.id(inputFieldId));
        SeleniumUtils.scrollToElement(By.id(inputFieldId));
        SeleniumUtils.typeText(By.id(inputFieldId), date + " " + month + " 2025", true);
        System.out.println("Field filled");
        SeleniumUtils.clickElement(By.xpath("//button[text()='Save']"));

        System.out.println("Saved");
        System.out.println("Test A1 for: " + scenario + " , " + lockSetup + " passed");
    }
}
