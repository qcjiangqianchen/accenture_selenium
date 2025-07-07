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
        
        System.out.println("✅ TCB1 END");
        Thread.sleep(10000);
    }

    public void filterByClassSubjectAssessment() throws Exception {
        List<WebElement> dropdowns = SeleniumUtils.getMinimumNumberOfDropdowns(3);
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(0), " SECONDARY 3 ");//level
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(1), " SEC3-01 ");//class
        SeleniumUtils.selectDropdownByVisibleText(dropdowns.get(2), " TERM 1 WA ");//assessment
        
    }
}
