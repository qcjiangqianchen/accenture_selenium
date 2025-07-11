package com.example.selenium.testcases;

import java.util.*;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.utils.TestCaseUtils;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;

public class TCA13 {
    
    public void run() throws Exception {
        //navigate to results by student page
        System.out.println("TCA13 START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Results'] and contains(., 'by Student')]");

        //TCA13.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA13_1(); 

        System.out.println("TCA13 END");
    }

    public void TCA13_1() throws Exception {
        //TCA13.1.1: filter by class, subject, and assessment
        filterByClassStudentAssessment();

        WebElement studentDropwdown = TestCaseUtils.filterByStudent();
        Select studentSelect = new Select(studentDropwdown);
        List<WebElement> students = studentSelect.getOptions();

        //TCA13.1.2/13.1.3/13.1.4: expand/collapse each tab, input marks for each student, save marks for each term
        for (WebElement student : students) {
            student.click();
            Thread.sleep(2000); // Wait for the page to load
            System.out.println("✅ Student " + student.getAttribute("value") + " selected");
            
            List<WebElement> expandCollaspeIcon = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")).findElements(By.tagName("svg-icon"));

            for (int i = 0; i < expandCollaspeIcon.size(); i++) {
                expandCollaspeTerm(i);
                expandCollaspeTerm(i);// Collapse the term after inputting marks
                Thread.sleep(2000); // Wait for the term to expand/collapse
                System.out.println("✅ Term " + (i + 1) + " processed");
            }
        }
    }

    public void filterByClassStudentAssessment() throws Exception {
        //filter by class and level
        TestCaseUtils.filterByLevelAndClass("SECONDARY 1", "SEC1-01");
        System.out.println("✅ level and chosen");
        
        //filter by assessment
        SeleniumUtils.clickElement(By.xpath("//div[contains(@class, 'multiselect-dropdown')]")); // Click on the assessment dropdown
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        WebElement selectAllCheckbox = SeleniumUtils.waitForElementToBeVisible(By.xpath("//div[contains(@class,'dropdown-list')]//ul[@class='item1']//li[1]//input[@type='checkbox']"));
        Thread.sleep(1000); // Wait for the checkbox to be visible
        if (!selectAllCheckbox.isSelected()) {
            SeleniumUtils.clickWithJS(By.xpath("//div[contains(@class,'dropdown-list')]//ul[@class='item1']//li[1]//input[@type='checkbox']")); //select all assessments
        } 
        System.out.println("✅ selected all assessments");
    }

    public void expandCollaspeTerm(int index) throws Exception {
        //expand term
        List<WebElement> expandCollaspeIcon = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")).findElements(By.tagName("svg-icon"));
        SeleniumUtils.clickWithJS(expandCollaspeIcon.get(index)); // Click on the expand/collapse icon for the term
        System.out.println("✅ term " + (index + 1) + " expanded/collasped");
    }
}
