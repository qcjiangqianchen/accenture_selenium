package com.example.selenium.utils;

import java.time.Duration;
import java.util.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.*;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.example.selenium.driver.DriverInstance;



public class SeleniumUtils{
    /*COMMON */
    // locates webelement and clicks on it
    public static void clickElement(By locator) {
        DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(locator)).click();
    }

    //initial test case setup; navigates to desired page
    public static void navigateToDesiredPage(String desiredPage) throws InterruptedException {
        //nav btns at top of page
        SeleniumUtils.clickElement(By.xpath("//div[contains(@class, 'site-new-menu')]//a[@data-target='#megaMenu-management2']"));

        //menu to go to results by class
        SeleniumUtils.clickElement(By.xpath(desiredPage));

        System.out.println("✅ Navigated to Results by Class page");
    }


    /*INPUT FIELDS */
    //text field input and press enter
    public static void typeText(By locator, String text, boolean pressEnter) {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator));
        element.clear();
        element.sendKeys(text);
        if (pressEnter)
            element.sendKeys(Keys.ENTER);
    }

    public static void typeText(WebElement element, String text, boolean pressEnter) {
        element.clear();
        element.sendKeys(text);
        if (pressEnter)
            element.sendKeys(Keys.ENTER);
    }


    /*DROPSDOWNS*/
    // By option text; dropdown not yet located
    public static void selectDropdownByVisibleText(By locator, String visibleText) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByVisibleText(visibleText);
    }

    // By option text; dropdown already previously defined and located
    public static void selectDropdownByVisibleText(WebElement element, String value) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOf(element)));
        dropdown.selectByVisibleText(value);
    }

    // By option value; dropdown not yet located
    public static void selectDropdownByValue(By locator, String value) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByValue(value);
    }

    // By option value; dropdown already previously defined and located
    public static void selectDropdownByValue(WebElement element, String value) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOf(element)));
        dropdown.selectByValue(value);
    }

        public static List<WebElement> getAllDropdowns() throws Exception {
        return DriverInstance.getDriver().findElements(By.tagName("select"));
    }

    public static List<WebElement> getMinimumNumberOfDropdowns(int expectedCount) throws Exception {
        return DriverInstance.getWait().until(driver1 -> {
            List<WebElement> dropdowns = driver1.findElements(By.tagName("select"));
            return dropdowns.size() >= expectedCount ? dropdowns : null;
        });
    }


    /*ELEMENT VISIBILITY*/
    //returns the text of a web element located by the given locator
    public static String getText(By locator) {
        return DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)).getText();
    }

    //returns boolean value to check if element is visible
    public static boolean isElementDisplayed(By locator) {
        try {
            return DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)).isDisplayed();
        } catch (TimeoutException e) {
            return false;
        }
    }

    //waits for webelement to be visible and returns it
    public static WebElement waitForElementToBeVisible(By locator){
        return DriverInstance.getWait()
            .until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    //waits for webelement to be invisible and returns boolean value
    public static boolean waitForElementToDisappear(By locator){
        return DriverInstance.getWait()
            .until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }


    /*SCROLLING AND HOVERING*/
    //scrolling into view of element
    public static void scrollToElement(WebElement element) throws Exception {
        ((JavascriptExecutor) DriverInstance.getDriver()).executeScript("arguments[0].scrollIntoView(true);", element);
    }

    //scrolling into view of element
    public static void scrollToElement(By locator) throws Exception {
        WebElement element = DriverInstance.getDriver().findElement(locator);
        ((JavascriptExecutor) DriverInstance.getDriver()).executeScript("arguments[0].scrollIntoView(true);", element);
    }

    //js execution of .click() function
    public static void clickWithJS(By locator) throws Exception {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(locator));
        ((JavascriptExecutor) DriverInstance.getDriver()).executeScript("arguments[0].click();", element);
    }

    // Utility method to get an Actions object using the global driver
    public static Actions getActions() throws Exception {
        return new Actions(DriverInstance.getDriver());
    }

    //move to element and hover
    public static void moveToElementAndHover(WebElement element) throws Exception {
        Actions actions = new Actions(DriverInstance.getDriver());
        actions.moveToElement(element).perform();
    }

    //move to element and hover
    public static void moveToElementAndHover(By locator) throws Exception {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator));
        Actions actions = new Actions(DriverInstance.getDriver());
        actions.moveToElement(element).perform();
    }
}