package com.example.selenium.loading;

import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.utils.TestCaseUtils;
import com.example.selenium.driver.DriverInstance;
import com.example.selenium.exception.ValidationFailedExecption;
import com.example.selenium.exception.InvalidExcpetion;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class SubjectAllocation {
    
    public void run(WebDriver driver) throws Exception {
        //navigate to subject allocation page
        System.out.println("Subject Allocation START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Subject'] and contains(., 'Allocation')]");

        //get all select tags
        List<WebElement> allSelectTags = SeleniumUtils.getMinimumNumberOfDropdowns(3);
        Thread.sleep(2000); 
        System.out.println("✅ allSelectTags count: " + allSelectTags.size());
        if (allSelectTags.size() < 3) {
            throw new RuntimeException("❌ Page did not load enough <select> elements. Found: " + allSelectTags.size());
        }
        WebElement yearSelect = allSelectTags.get(0);
        WebElement levelSelect = allSelectTags.get(1);
        WebElement courseSelect = allSelectTags.get(2);
        WebElement classSelect = SeleniumUtils.waitForElementToBeVisible(By.xpath("//div[contains(@id, 'search_row')]//div[contains(@class, 'multiselect-dropdown')]"));
        Thread.sleep(2000); 

        //subject allocation: assigning subject combinations to students in classes
        try {
            filterByYear(yearSelect);
            sortByLevelCLassCourse(levelSelect, courseSelect, classSelect);
        } catch (Exception e) {
            System.out.println("❌ An unexpected error occurred: " + e.getMessage());
        }
        System.out.println("✅ Subject Allocation END");
    }

    public void filterByYear(WebElement yearSelect) throws Exception {        
        //filter by year
        SeleniumUtils.selectDropdownByVisibleText(yearSelect, "2025");
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ year chosen: " + yearSelect.getAttribute("value"));
    }

    public void sortByLevelCLassCourse(WebElement levelSelect, WebElement courseSelect, WebElement classSelect) throws Exception{
        List<WebElement> option = SeleniumUtils.getAllOptionsFromDropdown(levelSelect); //get dropdown options for level

        for (int i = 1; i <= option.size(); i++) {
            SeleniumUtils.selectDropdownByVisibleText(levelSelect, " SECONDARY " + i);
            System.out.println("✅ Level selected: " + "SECONDARY " + i);
            if (i <= 2) {
                sec1And2SortByClass(classSelect, i);
            } else if (i == 3 || i == 4) {
                sec34And5SortByClass(classSelect, courseSelect, i);
            } else {
                sec34And5SortByClass(classSelect, courseSelect, i);
            }
        }
    }

    public void sec1And2SortByClass(WebElement classSelect, int level) throws Exception {
        System.out.println("Sorting by class for level: " + level);
        SeleniumUtils.clickElement(classSelect);
        WebElement classOption = SeleniumUtils.waitForElementToBeVisible(By.xpath("//div[contains(@class,'dropdown-list')]//ul[@class='item2']"));
        List<WebElement> options = classOption.findElements(By.xpath(".//li[contains(@class, 'multiselect-item-checkbox')]"));

        for (int i=3; i<options.size(); i++) {
            SeleniumUtils.clickElement(options.get(i));
            System.out.println("✅ Class selected: " + options.get(i).getText());

            //validation to check if class have students
            WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.xpath("//app-subject-allocation-secondary[contains(@id, 'main_table')]//nz-table"));
            if (!mainTable.getAttribute("class").contains("ant-table-empty")) {
                selectAllStudentsAndCourse(null, level);
                SeleniumUtils.clickElement(options.get(i)); //unselect class
            } else {
                throw new InvalidExcpetion("No students found for class: " + options.get(i).getText());
            }
        }
    }

    public void sec34And5SortByClass(WebElement classSelect, WebElement courseSelect, int level) throws Exception {
        System.out.println("Sorting by class for level: " + level);
        String[] streamTypes = {"EXPRESS", "N(A)", "N(T)"}; 
        
        SeleniumUtils.clickElement(classSelect);
        WebElement classOption = SeleniumUtils.waitForElementToBeVisible(By.xpath("//div[contains(@class,'dropdown-list')]//ul[@class='item2']"));
        List<WebElement> options = classOption.findElements(By.xpath(".//li[contains(@class, 'multiselect-item-checkbox')]"));

        //for each class check its streaming type
        for (int i=3; i<options.size(); i++) {
            boolean foundValidStreaming = false; //streaming type flag
            SeleniumUtils.clickElement(options.get(i)); //select class
            System.out.println("✅ Class selected: " + options.get(i).getText());

            // Try each of the 3 streaming types
            int streamCount = SeleniumUtils.getAllOptionsFromDropdown(courseSelect).size();
            for (int stream=0; stream < streamCount; stream++) {
                SeleniumUtils.selectDropdownByVisibleText(courseSelect, streamTypes[stream]); // select stream from dropdown
                System.out.println("✅ Streaming type selected: " + streamTypes[stream]);

                //validation if chosen class and course has students
                WebElement mainTable = SeleniumUtils.waitForElementToBeVisible(By.xpath("//app-subject-allocation-secondary[contains(@id, 'main_table')]//nz-table"));
                if (mainTable.getAttribute("class").contains("ant-table-empty")) {
                    System.out.println("❌Passing for " + streamTypes[stream] + "; no students found");
                    continue; // Skip to the next streaming type
                } else {
                    foundValidStreaming = true;
                    System.out.println("✅ Students found for " + streamTypes[stream]);
                    selectAllStudentsAndCourse(streamTypes[stream], level);
                    SeleniumUtils.clickElement(options.get(i)); //unselect class
                    break; // Found a valid streaming type, break out of the loop
                }
            }
            //throw exception if class has no valid streaming type
            if (!foundValidStreaming) throw new InvalidExcpetion("No valid streaming option found");
        }
    }

    public void selectAllStudentsAndCourse(String stream, int level) throws Exception {
        Map<String, String> sec3StreamTypes = new HashMap<>() {{
            put("EXPRESS", "S3E");
            put("N(A)", "S3N(A)");
            put("N(T)", "S3N(T)");
        }};

        Map<String, String> sec4StreamTypes = new HashMap<>() {{
            put("EXPRESS", "S4E");
            put("N(A)", "S4N(A)");
            put("N(T)", "S4N(T)");
        }};

        Map<String, String> sec5StreamTypes = new HashMap<>() {{
            put("N(A)", "S5N(A)");
            put("N(T)", "S5N(T)");
        }};

        //1. scroll to last checkbox at the bottom of the page
        List<WebElement> allCheckboxTags = DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.xpath("//checkbox[contains(@class, 'ng-untouched')]")));
        WebElement lastCheckbox = allCheckboxTags.get(allCheckboxTags.size() - 1);
        SeleniumUtils.scrollToElement(lastCheckbox);

        //2. select all students
        SeleniumUtils.clickElement(By.xpath("//app-subject-allocation-secondary[contains(@id, 'main_table')]//nz-table//thead//tr//th[1]//checkbox[contains(@class, 'ng-untouched')]//em[contains(@class, 'checkbox-icon')]"));
        System.out.println("✅ All students selected");
        List<WebElement> rows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//app-subject-allocation-secondary[contains(@id, 'main_table')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]"));
        System.out.println(rows.size());
        WebElement subjectSelect = SeleniumUtils.getMinimumNumberOfDropdowns(4).get(3);
        System.out.println(SeleniumUtils.getAllOptionsFromDropdown(subjectSelect).get(0).getText());
        WebElement dropDown = subjectSelect;

        //select corresponding combination to streaming
        if (level == 1) {
            SeleniumUtils.selectDropdownByVisibleText(dropDown, " Sec 1 G3 Subject Combi CL");
        } else if (level == 2) {
            SeleniumUtils.selectDropdownByVisibleText(dropDown, " Sec 2 G3 Subject Combi CL");
        } else if (level == 3) {
            SeleniumUtils.selectDropdownByVisibleText(dropDown, " " + sec3StreamTypes.get(stream) + " SubjectCombi SS&GEOG CL");
        } else if (level == 4) {
            SeleniumUtils.selectDropdownByVisibleText(dropDown, " " + sec4StreamTypes.get(stream) + " SubjectCombi SS&GEOG CL");
        } else if (level == 5) {
            SeleniumUtils.selectDropdownByVisibleText(dropDown, " " + sec5StreamTypes.get(stream) + " Subject Combi CL");
        }
        System.out.println("✅ Subject combination selected");

        //3. scroll to top
        SeleniumUtils.scrollToElement(TestCaseUtils.saveBtn());

        //4. save the subject combination
        //SeleniumUtils.clickElement(TestCaseUtils.saveBtn());

        //VALIDATION -> check if save button is disable to determine save success
        if (TestCaseUtils.saveBtn().getAttribute("disabled") != null || !TestCaseUtils.saveBtn().isEnabled()) {
            System.out.println("✅ Subject combi saved");
        } else {
            throw new ValidationFailedExecption("validation failed; subject combi not saved");
        }
    }
}




