// package com.example.selenium.loading;

// import com.example.selenium.setup.TCASetup;
// import com.example.selenium.driver.DriverInstance;

// import java.io.IOException;
// import java.nio.file.*;
// import java.sql.Driver;
// import java.util.List;
// import java.util.Set;

// import org.openqa.selenium.*;
// import org.openqa.selenium.support.ui.WebDriverWait;
// import org.openqa.selenium.support.ui.ExpectedConditions;

// public class SubjectAllocation {
//     private static WebDriver driver;
//     private static WebDriverWait wait;

//     public SubjectAllocation() {
//         driver = DriverInstance.getDriver();
//         wait = DriverInstance.getWait();
//     }
    

//     public static void run() throws InterruptedException {
//         //navigate to subject allocation page
//         System.out.println("Subject Allocation START");
//         TCASetup.navigateToDesiredPage(driver, wait, "//a[.//span[text()='Subject'] and contains(., 'Allocation')]");

//         //subject allocation: assigning subject combinations to students in classes

//     }

//     public void subjectAllocation(WebDriver driver, WebDriverWait wait) throws InterruptedException {
//         filterByYearLevelCourse(driver, wait);
//     }


//     public void filterByYearLevelCourse(WebDriver driver, WebDriverWait wait) throws InterruptedException {
//         //get all select tags
//         List<WebElement> allSelectTags = wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("select")));
//         WebElement yearSelect = allSelectTags.get(0);
//         WebElement levelSelect = allSelectTags.get(1);
//         WebElement courseSelect = allSelectTags.get(2);
//         WebElement subjectSelect = allSelectTags.get(3);

//         List<WebElement> allCheckboxTags = wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.tagName("checkbox")));
//         WebElement selectAllStudents = allCheckboxTags.get(0);
//         WebElement lastCheckbox = allCheckboxTags.get(allCheckboxTags.size() - 1);

//         //filter allocation year
//         sortByLevel(levelSelect);

//         //filter level
//         levelSelect.findElements(By.tagName("option")).get(2).click();
//         Thread.sleep(2000); // Wait for the page to load
//         System.out.println("✅ level chosen");

//         //filter by class
//         wait.until(ExpectedConditions.elementToBeClickable(By.className("dropdown-btn"))).click();
//         Thread.sleep(2000); // Wait for the dropdown to open
//         System.out.println("✅ class dropdown opened");
//         WebElement dropDownList = wait.until(ExpectedConditions.presenceOfElementLocated(By.className("dropdown-list")));
//         WebElement selectAllOption = dropDownList.findElements(By.tagName("ul")).get(0).findElements(By.tagName("li")).get(0);
//         List<WebElement> classOptions = dropDownList.findElements(By.tagName("ul")).get(1).findElements(By.tagName("li"));

//         for (WebElement classOption : classOptions) {
//             if (classOption.getText().equals("SEC3-01")) {
//                 classOption.click();
//                 break;
//             }
//         }
//     }

//     public void sortByLevelCLassCourse(WebElement levelSelect) throws InterruptedException {
//         //loop through level and filter by level
//         List<WebElement> levelOptions = levelSelect.findElements(By.tagName("option"));
//         for (WebElement option : levelOptions) {
//             option.click();
//             Thread.sleep(2000); // Wait for the page to load

//             //check the level and apply neccesary condition for streaming
//             String level = option.getText().trim();
//             if (level.equalsIgnoreCase("SECONDARY 1")) {
//                 //streaming not needed for sec 1
//                 System.out.println("✅ level chosen: " + level);
//             } else if (level.equalsIgnoreCase("SECONDARY 2")) {
//                 //loop through to select the classes first
//                 //set the streaming conditions according to level requirements            
//             } else if (level.equalsIgnoreCase("SECONDARY 3")) {
                
//             } else if (level.equalsIgnoreCase("SECONDARY 3")) {

//             } else if (level.equalsIgnoreCase("SECONDARY 3")) {
                
//             }


            
//         }
//     }

//     public void sortByClass(List<WebElement> classOptions) throws InterruptedException {
//         //assign subjects to classes 2 by 2
//         for (int i=0; i<classOptions.size(); i+=2) {
//             //check 2 classes at one go
//             classOptions.get(i).findElement(By.tagName("input")).click();
//             Thread.sleep(2000); // Wait for the page to load
//             classOptions.get(i+1).findElement(By.tagName("input")).click(); 
//             Thread.sleep(2000); // Wait for the page to load      
//         }
//     }

//     public void selectAllStudents(WebElement lastCheckbox, WebElement selectAllStudents, List<WebElement> allSelectTags, WebDriver driver) throws InterruptedException {
//         //select all students 
//         selectAllStudents.click();
//         Thread.sleep(2000); // Wait for the page to load
//         System.out.println("✅ All students selected");

//         //scroll to bottom
//         ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", allSelectTags.get(3));
//         Thread.sleep(2000); // Wait for the button to be in view


//         //select a proper subject combination - express SS+Geog combi
//         List<WebElement> subjectOptions = allSelectTags.get(3).findElements(By.tagName("option"));
//         for (WebElement option : subjectOptions) {
//             String combi = option.getText().trim();
//             if (combi.equalsIgnoreCase("S3E SubjectCombi SS&GEOG CL")) {
//                 option.click();
//                 Thread.sleep(2000); // Wait for the page to load
//                 System.out.println("✅ Subject combination selected: " + combi);
//                 break;
//             }
//         }

//         //scroll to top
//         WebElement saveBtn = wait.until(ExpectedConditions.elementToBeClickable(By.tagName("button")));
//         ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", saveBtn);

//         Thread.sleep(2000); // Wait for the button to be in view



        
//     }
// }
