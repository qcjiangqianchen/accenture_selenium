package com.example.selenium.testcases;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.utils.TestCaseUtils;

import java.util.*;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.interactions.Actions;

public class TCA16 {
    
    public void run() throws Exception {
        //navigate to results aggregated view by class
        System.out.println("TCA16 START");
        SeleniumUtils.navigateToDesiredPage("//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'Results Aggregated View by Class')]");

        //TCA13.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA16_1(); 

        System.out.println("TCA16 END");
    }

    public void TCA16_1() throws Exception {
        //TCA15.1.1: filter by class,assessment
        filterByClassAndAssessment();

        //TCA15.1.2: highlight each row in the main table
        highlightStudent(); // Highlight the first row as an example
    }

    public void filterByClassAndAssessment() throws Exception {   
        //filter by class and level
        TestCaseUtils.filterByLevelAndClass("SECONDARY 1", "SEC1-01");
        System.out.println("✅ level and chosen");

        // filter by assessment
        SeleniumUtils.selectDropdownByVisibleText(By.xpath("//div[contains(@class, 'dropdown-level-width')]//select"), "OVERALL");
        System.out.println("✅ assessment chosen");
    }

    public void highlightStudent() throws Exception {
        //get all rows
        WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")); //main table; dynamically refreshed within the function for each loop
        List<WebElement> rows = mainTable.findElements(By.cssSelector("div.ng-star-inserted"));

        for (int i=0; i<rows.size(); i++) {
            try {
                SeleniumUtils.scrollToElement(rows.get(i)); //move into view of element

                SeleniumUtils.moveToElementAndHover(rows.get(i));
                Thread.sleep(2000); // hovering
                
                System.out.println("✅ Hovered over row " + (i + 1));
            } catch (Exception e) {
                System.out.println("❌ Could not hover over row " + (i + 1) + ": " + e.getMessage());
            }
        }


        //header reference to scroll back to top
        WebElement header = SeleniumUtils.waitForElementToBeVisible(By.tagName("header"));
        SeleniumUtils.scrollToElement(header);  // Scroll back to top

    }
}
