package com.example.selenium.loading;

import com.example.selenium.utils.SeleniumUtils;
import com.example.selenium.driver.DriverInstance;
import com.example.selenium.exception.ValidationFailedExecption;
import com.example.selenium.exception.InvalidExcpetion;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class SubjectAllocation {
    
    public void run(WebDriver driver) throws InterruptedException {
        //navigate to subject allocation page
        System.out.println("Subject Allocation START");
        SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Subject'] and contains(., 'Allocation')]");

        //subject allocation: assigning subject combinations to students in classes
        try {
            filterByYearLevelCourse(driver);
        } catch (ValidationFailedExecption e) {
            System.out.println("❌ Validation failed: " + e.getMessage());
        } catch (InvalidExcpetion e) {
            System.out.println("❌ Invalid exception: " + e.getMessage());
        } catch (Exception e) {
            System.out.println("❌ An unexpected error occurred: " + e.getMessage());
        }
        System.out.println("✅ Subject Allocation END");

    }

    public void filterByYearLevelCourse(WebDriver driver) throws InterruptedException, ValidationFailedExecption {
        //get all select tags
        List<WebElement> allSelectTags = DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("select")));
         System.out.println("✅ allSelectTags count: " + allSelectTags.size());  // 👈 add this line

        if (allSelectTags.size() < 3) {
            throw new RuntimeException("❌ Page did not load enough <select> elements. Found: " + allSelectTags.size());
        }
        WebElement yearSelect = allSelectTags.get(0);
        WebElement levelSelect = allSelectTags.get(1);
        WebElement courseSelect = allSelectTags.get(2);

        //filter by year
        yearSelect.findElements(By.tagName("option")).get(1).click(); // Click on the first option in the year dropdown
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ year chosen: " + yearSelect.getAttribute("value"));


        //get class dropdown
        WebElement classSelect = DriverInstance.getWait().until(ExpectedConditions.presenceOfElementLocated(By.className("multiselect-dropdown")));
        classSelect.click(); // Click to open the class dropdown
        Thread.sleep(2000); // Wait for the dropdown to open
        List<WebElement> classOptions = classSelect.findElements(By.tagName("ul")).get(1).findElements(By.tagName("input"));  

        //filter by level, class, course; select students, and then assign subject combi 
        sortByLevelCLassCourse(levelSelect, courseSelect, classOptions, driver);
    }

    public void sortByLevelCLassCourse(WebElement levelSelect, WebElement courseSelect, List<WebElement> classOptions, WebDriver driver) throws InterruptedException, ValidationFailedExecption, InvalidExcpetion {
        //loop through level and filter by level
        List<WebElement> levelOptions = levelSelect.findElements(By.tagName("option"));
        for (WebElement option : levelOptions) {
            option.click();
            Thread.sleep(2000); // Wait for the page to load

            //check level and execute respective function
            String level = option.getText().trim();
            if (level.equalsIgnoreCase("SECONDARY 1")) {
                sec1And2SortByClass(classOptions, courseSelect, 2, driver);
            } else if (level.equalsIgnoreCase("SECONDARY 2")) {
                sec1And2SortByClass(classOptions, courseSelect, 2, driver);
                //set the streaming conditions according to level requirements            
            } else if (level.equalsIgnoreCase("SECONDARY 3")) {
                sec3And4SortByClass(classOptions, courseSelect, 3, driver);
            } else if (level.equalsIgnoreCase("SECONDARY 4")) {
                sec3And4SortByClass(classOptions, courseSelect, 4, driver);
            }
        }
    }

    public void sec1And2SortByClass(List<WebElement> classOptions, WebElement courseSelect, int level, WebDriver driver) throws InterruptedException, ValidationFailedExecption, InvalidExcpetion {
        //no streaming; loop through classes and select students and combi
        for (int i=0; i<classOptions.size(); i++) {
            classOptions.get(i).click(); // Click on the class option
            Thread.sleep(2000); // Wait for the page to load

            List<WebElement> allCheckboxTags = DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("checkbox")));

            // check if student list appears for respective class
            if (!allCheckboxTags.isEmpty()) {
                WebElement selectAllStudents = allCheckboxTags.get(0);
                WebElement lastCheckbox = allCheckboxTags.get(allCheckboxTags.size() - 1);

                selectAllStudentsAndCourse(lastCheckbox, selectAllStudents, allCheckboxTags, null, level, driver);
                System.out.println("✅ Students selected for class: " + classOptions.get(i).getText());
            }
        }
    }

    public void sec3And4SortByClass(List<WebElement> classOptions, WebElement courseSelect, int level, WebDriver driver) throws InterruptedException, ValidationFailedExecption, InvalidExcpetion {
        String[] streamTypes = {"express", "N(A)", "N(T)"}; 

        //check each class' stream type
        for (int i=0; i<classOptions.size()-1; i++) {

        boolean foundValidStreaming = false;

            // Try each of the 3 streaming types
            for (int stream=0; stream < 3; stream++) {
                courseSelect.findElements(By.tagName("option")).get(stream).click();  // Set streaming
                Thread.sleep(2000); // Wait for UI update

                List<WebElement> allCheckboxTags = DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("checkbox")));

                // check if student list appears for respective streaming
                if (!allCheckboxTags.isEmpty()) {
                    WebElement selectAllStudents = allCheckboxTags.get(0);
                    WebElement lastCheckbox = allCheckboxTags.get(allCheckboxTags.size() - 1);

                    selectAllStudentsAndCourse(lastCheckbox, selectAllStudents, allCheckboxTags, streamTypes[stream], level, driver);
                    foundValidStreaming = true;
                    break; // ✅ Found a valid streaming option, stop trying others
                }
            }
            
            // end of stream loop for 1 class; if no student list for any of the streaming, throw exception
            if (!foundValidStreaming) {
                throw new InvalidExcpetion("No valid streaming option found");
            }
        }
    }

    public void selectAllStudentsAndCourse(WebElement lastCheckbox, WebElement selectAllStudents, List<WebElement> allSelectTags, String stream, int level, WebDriver driver) throws InterruptedException, ValidationFailedExecption {
        Map<String, String> sec3StreamTypes = new HashMap<>() {{
            put("express", "S3E");
            put("N(A)", "S3N(A)");
            put("N(T)", "S3N(T)");
        }};

        Map<String, String> sec4StreamTypes = new HashMap<>() {{
            put("express", "S4E");
            put("N(A)", "S4N(A)");
            put("N(T)", "S4N(T)");
        }};

        //select all students 
        selectAllStudents.click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ All students selected");

        //scroll to bottom for subject combi button to be in view
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", allSelectTags.get(3));
        Thread.sleep(2000); // Wait for the button to be in view

        //select a proper subject combination - express SS+Geog combi
        List<WebElement> subjectOptions = allSelectTags.get(3).findElements(By.tagName("option"));
        for (WebElement option : subjectOptions) {
            String combi = option.getText().trim();
            if (level == 1) {
                if (combi.equalsIgnoreCase("Sec 1 G3 Subject Combi")) {
                    option.click();
                    Thread.sleep(2000); // Wait for the page to load
                    System.out.println("✅ Subject combination selected: " + combi);
                    break;
                }
            } else if (level == 2) {
                if (combi.equalsIgnoreCase("Sec 2 Subject Combi CL")) {
                    option.click();
                    Thread.sleep(2000); // Wait for the page to load
                    System.out.println("✅ Subject combination selected: " + combi);
                    break;
                }
            } else if (level == 3) {
                if (combi.equalsIgnoreCase(sec3StreamTypes.get(stream) + " SubjectCombi SS&GEOG CL")) {
                    option.click();
                    Thread.sleep(2000); // Wait for the page to load
                    System.out.println("✅ Subject combination selected: " + combi);
                    break;
                }
            } else if (level == 4) {
                if (combi.equalsIgnoreCase(sec4StreamTypes.get(stream) + " SubjectCombi SS&GEOG CL")) {
                    option.click();
                    Thread.sleep(2000); // Wait for the page to load
                    System.out.println("✅ Subject combination selected: " + combi);
                    break;
                }
            }
        }

        //scroll to top
        WebElement saveBtn = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.tagName("button")));
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", saveBtn);
        Thread.sleep(2000); // Wait for the button to be in view

        //save the subject combination
        saveBtn.click();
        Thread.sleep(2000); 

        //VALIDATION -> check if sve button is disable to determine save success
        if (saveBtn.getAttribute("disabled") != null) {
            System.out.println("✅ Subject combi saved");
        } else {
            throw new ValidationFailedExecption("validation failed; subject combi not saved");
        }
    }
}
