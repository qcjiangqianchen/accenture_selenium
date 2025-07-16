package com.example.selenium.testcases;

import com.example.selenium.utils.FileUtils;
import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.utils.TestCaseUtils;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.Select;

public class TCA11 {
    
    public void run() throws Exception {
        //navigate to results by class page
        System.out.println("TCA11 START");
        SeleniumUtils.navigateToDesiredPage( "//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'Results by Class / Teaching Group')]");

        Select subjectSelect = new Select(TestCaseUtils.filterByStudent());
        List<WebElement> subjects = subjectSelect.getOptions();

        for (WebElement subject : subjects) {
            subject.click();
            Thread.sleep(2000); // Wait for the page to load
            System.out.println("✅ Student " + subject.getAttribute("value") + " selected");

            //TCA11.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each subject; save marks for each term
            TCA11_1();

            //TCA11.2: download CSV file for each term; update CSV file with remarks
            TCA11_2();
        }
        System.out.println("✅ TCA11 END");
    }

    public void TCA11_1() throws Exception {
        //TCA11.1.1: filter by class, subject, and assessment
        filterByClassSubjectAssessment();

        //loop through each term in the main table
        WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA11.1.2/11.1.3/11.1.4: expand/collapse each tab, input marks for each student, save marks for each term
        for (int i=0; i<expandCollaspeIcon.size(); i++) {
            expandCollaspeTerm(i);
            inputMarks();
            saveMarks();    
            expandCollaspeTerm(i); // Collapse the term after inputting marks
            Thread.sleep(2000); // Wait for the term to expand/collapse
            System.out.println("✅ Term " + (i + 1) + " processed");
        }
    }

    public void TCA11_2() throws Exception {      
        //loop through each term in the main table
        WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA11.2.1/2.2/2.3: expand/collapse each tab, download file, and make edits to remarks
        for (int i = 0; i < expandCollaspeIcon.size(); i++) {
            try {
                expandCollaspeTerm(i);
                Set<String> before = FileUtils.getFilesBeforeDownload();
                if (before == null || before.isEmpty()) {
                    System.out.println("❌ No files found before download.");
                    continue; // Skip to the next iteration if no files were found
                }
                SeleniumUtils.clickWithJS(TestCaseUtils.downloadBtn()); //click the download icon
                Path filePath = FileUtils.waitForNewDownload(before, 15);
                updateCsvWithRemarks(filePath);
                expandCollaspeTerm(i);
            } catch (IOException e) {
                System.out.println("❌ Error updating CSV file: " + e.getMessage());
            } 
        }
    }

    public void filterByClassSubjectAssessment() throws Exception {
        //filter by class and level
        TestCaseUtils.filterByLevelAndClass("SECONDARY 3", "SEC3-01");
        System.out.println("✅ level and chosen");
        
        //filter by assessment
        SeleniumUtils.clickElement(By.xpath("//div[contains(@class, 'multiselect-dropdown')]")); // Click on the assessment dropdown
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

    public void inputMarks() throws Exception {
        //get all rows in the main table
        List<WebElement> rows = SeleniumUtils.waitForElementToBeVisible(By.id("main_table")).findElements(By.cssSelector("tr:not(.child_table)"));

        for (WebElement row:rows) {
            try {
                //find and clear input fields, enter marks
                WebElement inputField = row.findElement(By.tagName("input"));
                String randomMarks = String.valueOf((int) (Math.random() * 20));
                SeleniumUtils.typeText(inputField, randomMarks, false ); //input marks
                System.out.println("✅ Inputted marks: " + randomMarks + " for row: " + row.getText());
            } catch (NoSuchElementException e) {
                System.out.println("❌ No input for row: " + row.getText());
            }
        }
    }

    public void saveMarks() throws Exception {
        // WebElement searchContainer = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.id("search_row")));
        // WebElement  saveBtn = searchContainer.findElement(By.tagName("button"));

        SeleniumUtils.scrollToElement(TestCaseUtils.saveBtn()); //scroll to save btn

        // ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", saveBtn);
        Thread.sleep(2000); // Wait for the button to be in view

        try {
            SeleniumUtils.clickWithJS(TestCaseUtils.saveBtn()); //click save
            // ((JavascriptExecutor) driver).executeScript("arguments[0].click();", saveBtn);
            Thread.sleep(2000); // Wait for the save action to complete
            System.out.println("✅ Marks saved");
        } catch (ElementClickInterceptedException e) {
            System.out.println("❌ Save button was not clickable, possibly due to an overlay or modal.");
        } catch (Exception e) {
            System.out.println("❌ An unexpected error occurred while trying to save marks: " + e.getMessage());
        }
    }

    public void updateCsvWithRemarks(Path csvPath) throws IOException {
        List<String> lines = Files.readAllLines(csvPath);
        if (!lines.isEmpty()) {
            lines.set(0, lines.get(0) + ",remarks");
            for (int i = 1; i < lines.size(); i++) {
                lines.set(i, lines.get(i) + ",verified");
            }
        }
        Files.write(csvPath, lines);
        System.out.println("✅ CSV updated with remarks.");
    }
}
