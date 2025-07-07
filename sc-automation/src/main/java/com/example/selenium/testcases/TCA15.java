package com.example.selenium.testcases;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;

import java.util.*;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.interactions.Actions;

public class TCA15 {
    
    public void run(WebDriver driver) throws Exception {
        //navigate to results aggregated view by class 
        System.out.println("TCA15 START");
        SeleniumUtils.navigateToDesiredPage("//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'Results Aggregated View by Class')]");

        //TCA13.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA15_1(driver); 

        System.out.println("TCA15 END");
    }

    public void TCA15_1(WebDriver driver) throws Exception {
        //TCA15.1.1: filter by class,assessment
        filterByClassAndAssessment(driver);

        //TCA15.1.2: highlight each row in the main table
        highlightRow(driver); // Highlight the first row as an example
    }

    public void filterByClassAndAssessment(WebDriver driver) throws InterruptedException {   
        //navigate to level nav tab
        DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("a.site-menu-btn"))).get(2).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level nav tab accessed");

        //filter by level
        DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.xpath("//li[contains(@class, 'ng-star-inserted') and contains(text(), 'SECONDARY 3')]"))).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level chosen"); 

        //filter by class
        WebElement classContainer = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.id("megaMenu-level-tab-33")));
        List<WebElement> classGroup = classContainer.findElements(By.xpath(".//div[contains(@class, 'ng-star-inserted')]"));
        classGroup.get(0).findElement(By.xpath(".//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'SEC3-01')]")).click(); // Click on the first class group
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ class chosen");

        //filter by asessment
        WebElement assessmentSelect = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.tagName("select")));
        assessmentSelect.findElements(By.tagName("option")).get(0).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ assessment chosen");
    }

    public void highlightRow(WebDriver driver) throws Exception {
        //header reference to scroll back to top

        //get all rows
        WebElement mainTable = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> rows = mainTable.findElements(By.cssSelector("tr:not(.child_table)"));

        Actions actions = new Actions(driver);

        for (int i=0; i<rows.size(); i++) {
            try {
                actions.moveToElement(rows.get(i)).perform();
                Thread.sleep(1000); // For visibility
                System.out.println("✅ Hovered over row " + (i + 1));
            } catch (Exception e) {
                System.out.println("❌ Could not hover over row " + (i + 1) + ": " + e.getMessage());
            }
        }

        // Scroll back to top
        SeleniumUtils.scrollToElement(By.tagName("header"));
    }
}
