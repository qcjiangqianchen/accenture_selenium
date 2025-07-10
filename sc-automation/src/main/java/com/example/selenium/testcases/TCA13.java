package com.example.selenium.testcases;

import java.util.*;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.utils.TestCaseUtils;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class TCA13 {
    
    public void run(WebDriver driver) throws Exception {
        //navigate to results by student page
        System.out.println("TCA13 START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Results'] and contains(., 'by Student')]");

        //TCA13.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA13_1(driver); 

        System.out.println("TCA13 END");
    }

    public void TCA13_1(WebDriver driver) throws Exception {
        //TCA13.1.1: filter by class, subject, and assessment
        filterByClassStudentAssessment(driver);

        //loop through each term in the main table
        WebElement mainTable = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA13.1.2/13.1.3/13.1.4: expand/collapse each tab, input marks for each student, save marks for each term
        for (int i = 0; i < expandCollaspeIcon.size(); i++) {
            expandCollaspeTerm(driver, i);
            expandCollaspeTerm(driver, i); // Collapse the term after inputting marks
            Thread.sleep(2000); // Wait for the term to expand/collapse
            System.out.println("✅ Term " + (i + 1) + " processed");
        }
    }

    public void filterByClassStudentAssessment(WebDriver driver) throws Exception {
        //filter by class and level
        TestCaseUtils.filterByLevelAndClass("SECONDARY 1", "SEC1-01");
        System.out.println("✅ level and chosen");

        //filter by student
        WebElement studentSelect = SeleniumUtils.waitForElementToBeVisible(By.tagName("select"));
        studentSelect.findElements(By.tagName("option")).get(1).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ student chosen");

        //filter by asessment
        SeleniumUtils.clickElement(By.className("dropdown-btn"));
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        SeleniumUtils.clickElement(By.className("dropdown-btn"));
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        System.out.println("TCA13.1.2 successful");
    }

    public void expandCollaspeTerm(WebDriver driver, int index) throws InterruptedException {
        //expand term
        WebElement mainTable = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", expandCollaspeIcon.get(index));
        System.out.println("✅ term " + (index + 1) + " expanded/collasped");
    }
}
