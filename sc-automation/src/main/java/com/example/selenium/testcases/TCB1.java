package com.example.selenium.testcases;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;

public class TCB1 {
    public void run(WebDriver driver) throws Exception {
        //navigate to results by class page
        System.out.println("TCB1 START");
        SeleniumUtils.navigateToDesiredPage( "//li[contains(@class, 'child-module')]//a[contains(text(), 'Moderation')]");
        filterByClassSubjectAssessment();
        //loop through each term in the main table
        WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")); //main table; dynamically refreshed within the function for each loop
        List<WebElement> rows = mainTable.findElements(By.cssSelector("tr.ant-table-row"));
        Thread.sleep(1000);
        int counter = 0;
        for (WebElement row : rows) {
            if (counter == 5)
                break; // Limit to 5 rows for testing purposes
            // Find the cell with the student name (assuming it's the 4th cell <td> in the row)
            List<WebElement> inputFields = row.findElements(By.tagName("input"));
            if (!inputFields.isEmpty()) {
                counter++;
                SeleniumUtils.typeText(getInputField(row, 0), "6", true);
                SeleniumUtils.typeText(getInputField(row, 1), "65", true);
                SeleniumUtils.typeText(getInputField(row, 2), "17", true);
                SeleniumUtils.typeText(getInputField(row, 3), "14", true);
                SeleniumUtils.typeText(getInputField(row, 4), "18", true);
                SeleniumUtils.typeText(getInputField(row, 5), "15", true);
                SeleniumUtils.typeText(getInputField(row, 6), "5", true);
                SeleniumUtils.typeText(getInputField(row, 7), "3.2", true);
                WebElement passIndicator = row.findElement(By.tagName("select"));
                SeleniumUtils.selectDropdownByVisibleText(passIndicator, "PASS");
            }
        }
        SeleniumUtils.scrollToElement(By.xpath("//button[text()='Save']"));
        SeleniumUtils.clickElement(By.xpath("//button[text()='Save']"));
        System.out.println("✅ TCB1 END");
        Thread.sleep(10000);
    }

    public void filterByClassSubjectAssessment() throws Exception {
        List<WebElement> dropdowns = SeleniumUtils.getMinimumNumberOfDropdowns(3);
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(0), " SECONDARY 3 ");//level
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(1), " SEC3-01 ");//class
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(2), " TERM 1 WA ");//assessment
        
    }

    public static WebElement getInputField(WebElement row, int inputFieldIndex) {
        List<WebElement> inputFields = row.findElements(By.tagName("input"));

        if (inputFields.isEmpty()) {
            throw new IllegalStateException("No input fields found in this row.");
        }

        if (inputFieldIndex >= 0 && inputFieldIndex < inputFields.size()) {
            return inputFields.get(inputFieldIndex);
        } else {
            throw new IndexOutOfBoundsException("Invalid input field index: " + inputFieldIndex +
                ". Found " + inputFields.size() + " input(s) in the row.");
        }
    }
}
