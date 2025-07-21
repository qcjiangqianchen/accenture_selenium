    package com.example.selenium.loading;

    import java.util.List;

    import org.openqa.selenium.By;
    import org.openqa.selenium.WebElement;

    import com.example.selenium.exception.ValidationFailedExecption;
    import com.example.selenium.utils.SeleniumUtils;
    import com.example.selenium.utils.TestCaseUtils;

    public class SubjectSetup {
        
        public void run() throws Exception{
            //navigate to subject setup page
            System.out.println("Subject Allocation START"); 
            SeleniumUtils.navigateToDesiredPage("//a[.//span[text()='Subject'] and contains(., 'Setup')]");

            //get all select tags
            List<WebElement> allSelectTags = SeleniumUtils.getMinimumNumberOfDropdowns(3);
            Thread.sleep(2000); 
            System.out.println("✅ allSelectTags count: " + allSelectTags.size());
            if (allSelectTags.size() < 3) throw new RuntimeException("❌ Page did not load enough <select> elements. Found: " + allSelectTags.size());
            WebElement yearSelect = allSelectTags.get(0);
            WebElement levelSelect = allSelectTags.get(1);

            //for each level set the subject type and input weightage
            try {
                filterByYear(yearSelect);
                List<WebElement> yearOptions = SeleniumUtils.getAllOptionsFromDropdown(levelSelect);
                for (int i=0; i<yearOptions.size(); i++) {
                    filterByLevel(levelSelect, yearOptions.get(i).getText());
                    filterSubjectType();
                    setWeightage();
                }
            } catch (Exception e) {
                System.out.println("❌ Error during subject setup: " + e.getMessage());
                throw e;
            } 
            System.out.println("Subject Setup END");
        }

        public void filterByYear(WebElement yearSelect) throws Exception {        
            SeleniumUtils.selectDropdownByVisibleText(yearSelect, "2025");
            System.out.println("✅ year chosen: " + yearSelect.getAttribute("value"));
        }

        public void filterByLevel(WebElement levelSelect, String level) throws Exception {
            SeleniumUtils.selectDropdownByVisibleText(levelSelect, level);
            System.out.println("✅ level chosen: " + levelSelect.getAttribute("value"));        
        }

        public void filterSubjectType() throws Exception {
            TestCaseUtils.customDropdownAssessmentSelectAll();
            System.out.println("✅ subject category chosen");
        }

        public void setWeightage() throws Exception {
            int numRows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//div[contains(@id, 'main_table')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]")).size();
            
            //loop through each row and set weightage
            for (int i = 0; i < numRows; i++) {
                List<WebElement> rows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//div[contains(@id, 'main_table')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]"));
                SeleniumUtils.clickElement(rows.get(i).findElement(By.xpath(".//td[1]//checkbox[contains(@class, 'ng-untouched')]//em[contains(@class, 'checkbox-icon')]")));
                System.out.println("✅ Row selected for input");
                String resultEntryType = SeleniumUtils.waitForElementToBeVisible(rows.get(i).findElement(By.xpath(".//td[7]//span"))).getText();

                //validate arrow is clicked and down
                SeleniumUtils.clickElement(By.xpath("//app-component-set-up-multiple-subject-marks[contains(@class, 'ng-star-inserted')]//nz-table//thead//tr//th[1]//svg-icon"));
                if (SeleniumUtils.waitForElementToBeVisible(By.xpath("//app-component-set-up-multiple-subject-marks[contains(@class, 'ng-star-inserted')]//nz-table//thead//tr//th[1]//svg-icon//img")).getAttribute("src").contains("angle-double-up.svg")) {
                    System.out.println("✅ Arrow clicked");
                } else throw new ValidationFailedExecption("validation failed; arrow buton not clicked and not down");

                if (resultEntryType.equals("Marks")) {
                    setMarks(); }
                // } else if (resultEntryType.equals("Grades")) {
                    
                // }
                
            }
        }

        public void setMarks() throws Exception {
            int numRows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//app-component-set-up-multiple-subjects-marks[contains(@class, 'ng-star-inserted')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]")).size();
            
            for (int i=0; i<numRows; i++) {
                List<WebElement> rows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//app-component-set-up-multiple-subjects-marks[contains(@class, 'ng-star-inserted')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]"));
                WebElement row = rows.get(i);
                String assessmentType = SeleniumUtils.waitForElementToBeVisible(row.findElement(By.xpath(".//td[2]"))).getText();
                try {
                    //condition 1; check if the row has a input field; input weightage according to type of assessment
                    if (!row.findElements(By.tagName("input")).isEmpty()) {
                        if (assessmentType.equals("Weighted")) {
                            SeleniumUtils.typeText(row.findElements(By.tagName("input")).get(0), "15", false);
                        } else if (assessmentType.equals("End-of-year Exam"))  {
                            SeleniumUtils.typeText(row.findElements(By.tagName("input")).get(0), "55", false);
                        }
                        continue;
                    } 

                    //condition 2; check if the row allows for addition of new row to add components
                    if (!row.findElements(By.xpath(".//svg-icon[contains(@icon_name, 'addRow')]")).isEmpty()) {
                        SeleniumUtils.clickWithJS(row.findElement(By.xpath("//svg-icon[contains(@icon_name, 'addRow')]")));
                        setComponent(i); //added row gets the index of the preious row
                        continue;
                    } 
                } catch (Exception e) {
                    System.out.println("❌ Error processing row: " + e.getMessage());
                }
            }   
        }

        public void setComponent(int index) throws Exception{
            List<WebElement> rows = SeleniumUtils.waitForAllElementsToBeVisible(By.xpath("//app-component-set-up-multiple-subjects-marks[contains(@class, 'ng-star-inserted')]//nz-table//tbody/tr[contains(@class, 'ant-table-row') and contains(@class, 'ng-star-inserted')]"));
            WebElement row = rows.get(index);
            
            //validate row
            if ((SeleniumUtils.waitForElementToBeVisible(row.findElement(By.xpath("//svg-icon[contains(@icon_name, 'deleteRow')]"))).getAttribute("src").contains("deleteRow.svg"))) {
                System.out.println("✅ Added row present");
            } else throw new ValidationFailedExecption("validation failed; arrow buton not clicked and not down");

            SeleniumUtils.typeText(row.findElements(By.tagName("input")).get(1), "100", false); //component weightings
            SeleniumUtils.typeText(row.findElements(By.tagName("input")).get(2), "100", false); //component weightings
        }
    }
