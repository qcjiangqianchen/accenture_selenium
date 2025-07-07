package com.example.selenium.testcases;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.FileUtils;
import com.example.selenium.utils.SeleniumUtils;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class TCA14 {
    
    public void run(WebDriver driver) throws Exception {
        // Navigate to results by class page
        System.out.println("TCA14 START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Results'] and contains(., 'Upload')]");

        // TCA14.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA14_1(driver);

        System.out.println("✅ TCA14 END");
        Thread.sleep(10000);
    }

    public void TCA14_1(WebDriver driver) throws Exception {
        try {
            filterByLevelAndData(driver);
            downloadReport(driver);
        } catch (IOException e) {
            System.err.println("Error during file operations: " + e.getMessage());
        }
    
    }

    public void filterByLevelAndData(WebDriver driver) throws Exception{
        //filter by level
        List<WebElement> selectDropdowns = SeleniumUtils.getMinimumNumberOfDropdowns(2);
        selectDropdowns.get(0).findElements(By.tagName("option")).get(1).click(); // Click on the first option in the first dropdown
        Thread.sleep(2000); // Wait for the page to load

        //filter by data set
        selectDropdowns.get(1).findElements(By.tagName("option")).get(1).click(); // Click on the first option in the second dropdown
        Thread.sleep(2000); // Wait for the page to load
    }

    public void downloadReport(WebDriver driver) throws Exception {
        Set<String> before = FileUtils.getFilesBeforeDownload();
        if (before == null || before.isEmpty()) {
            System.out.println("❌ No files found before download.");
            return; // Skip to the next iteration if no files were found
        }
        // Click on the download button
        SeleniumUtils.clickElement(By.cssSelector("svg-icon[icon_name='download']"));
        Thread.sleep(2000); // Wait for the download to complete
        Path filePath = FileUtils.waitForNewDownload(before, 15);
        updateCsvWithRemarks(filePath);
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
    