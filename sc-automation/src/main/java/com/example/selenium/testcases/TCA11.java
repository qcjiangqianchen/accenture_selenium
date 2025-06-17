package com.example.selenium.testcases;

import com.example.selenium.setup.TCASetup;
import com.example.selenium.utils.FileUtils;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class TCA11 {
    
    public void run(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //navigate to results by class page
        System.out.println("TCA11 START");
        TCASetup.navigateToDesiredPage(driver, wait, "//li[contains(@class, 'ng-star-inserted')]//a[contains(text(), 'Results by Class / Teaching Group')]");

        //TCA11.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA11_1(driver, wait);

        //TCA11.2: download CSV file for each term; update CSV file with remarks
        TCA11_2(driver, wait);
        
        System.out.println("✅ TCA11 END");
    }

    public void TCA11_1(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //TCA11.1.1: filter by class, subject, and assessment
        filterByClassSubjectAssessment(driver, wait);

        //loop through each term in the main table
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA11.1.2/11.1.3/11.1.4: expand/collapse each tab, input marks for each student, save marks for each term
        for (int i=0; i<expandCollaspeIcon.size(); i++) {
            expandCollaspeTerm(driver, wait, i);
            inputMarks(driver, wait);
            saveMarks(driver, wait);    
            expandCollaspeTerm(driver, wait, i); // Collapse the term after inputting marks
            Thread.sleep(2000); // Wait for the term to expand/collapse
            System.out.println("✅ Term " + (i + 1) + " processed");
        }
    }

    public void TCA11_2(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        // filterByClassSubjectAssessment(driver, wait);
        
        //loop through each term in the main table
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));

        //TCA11.2.1/2.2/2.3: expand/collapse each tab, download file, and make edits to remarks
        for (int i = 0; i < expandCollaspeIcon.size(); i++) {
            try {
                expandCollaspeTerm(driver, wait, i);
                Set<String> before = FileUtils.getFilesBeforeDownload();
                WebElement downloadIcon = wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector("svg-icon[icon_name='download']")));
                downloadIcon.click();
                Path filePath = FileUtils.waitForNewDownload(before, 15);
                updateCsvWithRemarks(filePath);
                expandCollaspeTerm(driver, wait, i);
            } catch (IOException e) {
                System.out.println("❌ Error updating CSV file: " + e.getMessage());
            } 

        }
    }

    public void filterByClassSubjectAssessment(WebDriver driver, WebDriverWait wait) throws InterruptedException {
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
        WebElement searchContainer = wait.until(ExpectedConditions.elementToBeClickable(By.id("search_row")));
        WebElement subjectSelect = searchContainer.findElement(By.tagName("select"));
        List<WebElement> options = subjectSelect.findElements(By.tagName("option"));
        options.get(1).click(); // Select the second option (e.g., 'English Language')
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ subject chosen");

        //filter by assessment
        searchContainer.findElement(By.className("dropdown-btn")).click();
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        searchContainer.findElement(By.className("dropdown-btn")).click();
        Thread.sleep(2000); // Wait for the dropdown to open
        System.out.println("✅ assessment dropdown opened");
        System.out.println("TCA11.1.1 successful");
    }

    public void expandCollaspeTerm(WebDriver driver, WebDriverWait wait, int index) throws InterruptedException {
        //expand term
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> expandCollaspeIcon = mainTable.findElements(By.tagName("svg-icon"));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", expandCollaspeIcon.get(index));
        System.out.println("✅ term " + (index + 1) + " expanded/collasped");
    }

    public void inputMarks(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement mainTable = wait.until(ExpectedConditions.presenceOfElementLocated(By.id("main_table"))); //main table; dynamically refreshed within the function for each loop
        List<WebElement> rows = mainTable.findElements(By.cssSelector("tr:not(.child_table)"));
        for (WebElement row:rows) {
            try {
                //find and clear input fields
                WebElement inputField = row.findElement(By.tagName("input"));
                inputField.clear();

                //input marks
                String randomMarks = String.valueOf((int) (Math.random() * 20));
                inputField.sendKeys(randomMarks);
                Thread.sleep(500);
                System.out.println("✅ Inputted marks: " + randomMarks + " for row: " + row.getText());
            } catch (NoSuchElementException e) {
                System.out.println("❌ No input for row: " + row.getText());
            }
        }
    }

    public void saveMarks(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        WebElement searchContainer = wait.until(ExpectedConditions.elementToBeClickable(By.id("search_row")));
        WebElement  saveBtn = searchContainer.findElement(By.tagName("button"));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", saveBtn);
        Thread.sleep(2000); // Wait for the button to be in view

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
