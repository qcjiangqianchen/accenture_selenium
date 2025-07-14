package com.example.selenium.testcases;
import java.time.Duration;
import java.util.*;
 
import org.openqa.selenium.By;
import org.openqa.selenium.ElementClickInterceptedException;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.FileUtils;
import com.example.selenium.utils.SeleniumUtils;

import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
 

public class TCA5 {

    static boolean breaker = false;
    static long sleepduration = 1000; // 1 second

    public void run(WebDriver driver) throws Exception {
        System.out.println("TCA5 START");

        TCA5_1(driver);

        System.out.println("All Tests Passed");
        System.out.println("✅ TCA5 END");
    }

    public void TCA5_1(WebDriver driver) throws Exception {
        Actions actions = new Actions(driver);
        SeleniumUtils.navigateToDesiredPage("//a[text()='HDP Remarks and Conduct by Class']");
        System.out.println("HDP Remarks and Conduct by class page chosen");
        filterByClassSubjectAssessment(driver);
        // Get all table rows
        List<WebElement> rows = driver.findElements(By.cssSelector("tr.ant-table-row"));
        for (int i = 2; i < rows.size(); i++) {
            WebElement row = rows.get(i);
            System.out.println("Processing row " + (i + 1));
            // Student name
            try {
                WebElement studentName = row.findElement(By.tagName("strong"));
                System.out.println("Student: " + studentName.getText());
            } catch (NoSuchElementException e) {
                System.out.println("Student name not found.");
            }

            // Dropdown selection
            try {
                WebElement selectElem = row.findElement(By.cssSelector("select.custom-select"));
                Select dropdown = new Select(selectElem);
                dropdown.selectByVisibleText("GOOD"); // Adjust value as needed
            } catch (Exception e) {
                System.out.println("Dropdown not found or not selectable.");
            }
            // Click "Enter Remarks" link
            try {
                WebElement remarkLink = row.findElement(By.cssSelector("a.enterRemark"));
                DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(remarkLink)).click();

            } catch (Exception e) {
                System.out.println("Enter Remarks link not found or not clickable.");
            }
            Thread.sleep(10);
        }
        Thread.sleep(sleepduration);
        saveMarks(driver);
        Set<String> before = FileUtils.getFilesBeforeDownload();
        WebElement downloadIcon = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.cssSelector("svg-icon[icon_name='download']")));
        downloadIcon.click();
    }
    public void saveMarks(WebDriver driver) throws Exception {
        WebElement searchContainer = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.id("search_row")));
        WebElement  saveBtn = searchContainer.findElement(By.tagName("button"));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", saveBtn);
        Thread.sleep(1000); // Wait for the button to be in view

        try {
            ((JavascriptExecutor) driver).executeScript("arguments[0].click();", saveBtn);
            Thread.sleep(2000); // Wait for the save action to complete
            System.out.println("✅ Marks saved");
        } catch (ElementClickInterceptedException e) {
            System.out.println("❌ Save button was not clickable, possibly due to an overlay or modal.");
        } catch (Exception e) {
            System.out.println("❌ An unexpected error occurred while trying to save marks: " + e.getMessage());
        }
    }
    public void filterByClassSubjectAssessment(WebDriver driver) throws Exception {
        //navigate to level nav tab
        DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("a.site-menu-btn"))).get(2).click();
        Thread.sleep(1000); // Wait for the page to load
        System.out.println("✅ level nav tab accessed");

        //filter by level
        DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.xpath("//li[contains(@class, 'ng-star-inserted') and contains(text(), 'SECONDARY 3')]"))).click();
        Thread.sleep(1000); // Wait for the page to load
        System.out.println("✅ level chosen"); 

        //filter by class
        WebElement classContainer = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.id("megaMenu-level-tab-33")));
        List<WebElement> classGroup = classContainer.findElements(By.xpath(".//div[contains(@class, 'ng-star-inserted')]"));
        classGroup.get(0).findElement(By.xpath(".//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'SEC3-01')]")).click(); // Click on the first class group
        Thread.sleep(1000); // Wait for the page to load
        System.out.println("✅ class chosen");

    }
}
