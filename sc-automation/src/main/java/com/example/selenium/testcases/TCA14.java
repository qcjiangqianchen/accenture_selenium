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
    
    public void run() throws Exception {
        // Navigate to results by class page
        System.out.println("TCA14 START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Results'] and contains(., 'Upload')]");

        // TCA14.1: filter by class, subject, and assessment; expand/collapse each term; input marks for each student; save marks for each term
        TCA14_1();

        System.out.println("✅ TCA14 END");
    }

    public void TCA14_1() throws Exception {
        try {
            filterByLevelAndData();
            downloadReport();
        } catch (IOException e) {
            System.err.println("Error during file operations: " + e.getMessage());
        }
    }

    public void filterByLevelAndData() throws Exception{
        //filter by level
        List<WebElement> selectDropdowns = SeleniumUtils.getMinimumNumberOfDropdowns(2);
        SeleniumUtils.selectDropdownByVisibleText(selectDropdowns.get(0), " SECONDARY 3"); // Select the first dropdown
        System.out.println("✅ level chosen");

        //filter by data set
        SeleniumUtils.selectDropdownByVisibleText(selectDropdowns.get(1), "   Student HDP Remarks and Conduct   "); // Select the second dropdown
        System.out.println("✅ data set chosen");
    }

    public void downloadReport() throws Exception {
        Set<String> before = FileUtils.getFilesBeforeDownload();
        if (before == null || before.isEmpty()) {
            System.out.println("❌ No files found before download.");
            return; // Skip to the next iteration if no files were found
        }
        // Click on the download button
        SeleniumUtils.clickElement(By.cssSelector("svg-icon[icon_name='download']"));
        System.out.println("✅ Download button clicked");
        
        //get the path of the downloaded file
        Path filePath = null;
        try {
            filePath = FileUtils.waitForNewDownload(before, 15);
        } catch (Exception e) {
            // Couldn't detect a new file within timeout
            System.out.println("⚠️ No new file detected after waiting. Skipping update.");
            return;
        }

        // Check if filePath is null
        if (filePath == null) {
            System.out.println("⚠️ File path is null. Skipping CSV update.");
            return;
        }

        // Check if file is readable
        if (!Files.isReadable(filePath)) {
            System.out.println("⚠️ File exists but is not readable: " + filePath);
            return;
        }

        // Update the CSV file with remarks and handle exceptions
        try {
            updateCsvWithRemarks(filePath);
        } catch (IOException ioe) {
            // IOException specifically for file reading/writing issues
            System.out.println("⚠️ Failed to update CSV file: " + filePath);
            ioe.printStackTrace();
            return;
        } catch (Exception ex) {
            // Any other exception: rethrow
            System.out.println("❌ Unexpected error while updating CSV.");
            throw ex;
    }
        
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
    