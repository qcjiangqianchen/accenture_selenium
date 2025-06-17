package com.example.selenium.testcases;

import com.example.selenium.setup.TCASetup;

import java.util.*;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.interactions.Actions;


public class TCA7 {
    
    public void run(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //navigate to results aggregated view by class 
        System.out.println("TCA7 START");
        TCASetup.navigateToDesiredPage(driver, wait, "//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'Subject Remarks by Class / Teaching Group')]");

        //TCA7.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA7_1(driver, wait); 

        System.out.println("TCA7 END");
    }

    public void TCA7_1(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //TCA7.1.1: filter by class, subject, and assessment
        filterByClassSubjectAssessment(driver, wait);

        //TCA7.1.2: enter remarks for each student
        enterRemarks(driver, wait);
    }

    public void TCA7_2(WebDriver driver, WebDriverWait wait) {

    }

    public void filterByClassSubjectAssessment(WebDriver driver, WebDriverWait wait) throws InterruptedException{
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

        //filter by subject
        List<WebElement> selectDropdowns = wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("select")));
        selectDropdowns.get(0).findElements(By.tagName("option")).get(1).click(); // Click on the first option in the first dropdown
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ subject chosen");

        //filter by assessment
        selectDropdowns.get(0).findElements(By.tagName("option")).get(1).click(); // Click on the first option in the first dropdown
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ assessment chosen");

    }


    public void enterRemarks(WebDriver driver, WebDriverWait wait) throws InterruptedException{
        //get all rows
        List<WebElement> rows = wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("tr:not(.child_table)")));
        
        Actions actions = new Actions(driver);

        for (WebElement row:rows) {
            try {
                //click on remark field
                WebElement remarkField = row.findElement(By.cssSelector("a.enterRemark"));
                ((JavascriptExecutor) driver).executeScript("arguments[0].click();", remarkField);
                Thread.sleep(1000); // Wait for the field to be clickable

                //enter remark; wait for the dynamic textarea to appear
                WebElement textArea = wait.until(
                    ExpectedConditions.visibilityOfElementLocated(By.cssSelector("div.textarea-remark[contenteditable='true']"))
                );
                textArea.sendKeys("This is a test remark for " + row.getText());

                // Close textarea by clicking outside — click the row itself
                actions.moveToElement(row).click().perform(); // closes the textarea
                Thread.sleep(500);

                System.out.println("✅ Entered remark for row: " + row.getText());
            } catch (Exception e) {
                System.out.println("❌ No input for row: " + row.getText());
            }
        }
    }
}
