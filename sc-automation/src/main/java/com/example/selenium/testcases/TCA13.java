package com.example.selenium.testcases;

import java.util.*;

import com.example.selenium.setup.TCASetup;
import com.example.selenium.utils.SeleniumUtils;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class TCA13 {
    
    public void run(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //navigate to results by student page
        System.out.println("TCA13 START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Results'] and contains(., 'by Student')]");

        //TCA13.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA13_1(driver, wait); 

        System.out.println("TCA13 END");
    }

    public void TCA13_1(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //TCA13.1.1: filter by class, subject, and assessment
        filterByClassStudentAssessment(driver, wait);

        //loop through each term in the main table
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA13.1.2/13.1.3/13.1.4: expand/collapse each tab, input marks for each student, save marks for each term
        for (int i = 0; i < expandCollaspeIcon.size(); i++) {
            expandCollaspeTerm(driver, wait, i);
            expandCollaspeTerm(driver, wait, i); // Collapse the term after inputting marks
            Thread.sleep(2000); // Wait for the term to expand/collapse
            System.out.println("✅ Term " + (i + 1) + " processed");
        }
    }

    public void filterByClassStudentAssessment(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //navigate to level nav tab
        wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("a.site-menu-btn"))).get(2).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level nav tab accessed");

        //filter by level
        wait.until(ExpectedConditions.presenceOfElementLocated(By.xpath("//li[contains(@class, 'ng-star-inserted') and contains(text(), 'SECONDARY 3')]"))).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level chosen"); 

        //filter by class
        WebElement classContainer = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("megaMenu-level-tab-33")));
        List<WebElement> classGroup = classContainer.findElements(By.xpath(".//div[contains(@class, 'ng-star-inserted')]"));
        classGroup.get(0).findElement(By.xpath(".//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'SEC3-01')]")).click(); // Click on the first class group
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ class chosen");

        //filter by student
        WebElement studentSelect = wait.until(ExpectedConditions.elementToBeClickable(By.tagName("select")));
        studentSelect.findElements(By.tagName("option")).get(1).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ student chosen");

        //filter by asessment
        wait.until(ExpectedConditions.elementToBeClickable(By.className("dropdown-btn"))).click();
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        wait.until(ExpectedConditions.elementToBeClickable(By.className("dropdown-btn"))).click();
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        System.out.println("TCA13.1.2 successful");
    }

    public void expandCollaspeTerm(WebDriver driver, WebDriverWait wait, int index) throws InterruptedException {
        //expand term
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", expandCollaspeIcon.get(index));
        System.out.println("✅ term " + (index + 1) + " expanded/collasped");
    }
}
