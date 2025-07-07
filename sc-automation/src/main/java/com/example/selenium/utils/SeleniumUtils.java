package com.example.selenium.utils;

import java.time.Duration;
import java.util.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.example.selenium.driver.DriverInstance;



public class SeleniumUtils{

    public static void clickElement(By locator) {
        DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(locator)).click();
    }

    public static void navigateToDesiredPage(String desiredPage) throws InterruptedException
    {
        //nav btns at top of page
        SeleniumUtils.clickElement(By.xpath("//div[contains(@class, 'site-new-menu')]//a[@data-target='#megaMenu-management2']"));

        //menu to go to results by class
        SeleniumUtils.clickElement(By.xpath(desiredPage));

        System.out.println("✅ Navigated to Results by Class page");
    }

    public static void typeText(By locator, String text, boolean pressEnter) {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator));
        element.clear();
        element.sendKeys(text);
        if (pressEnter)
            element.sendKeys(Keys.ENTER);
    }

    public static String getText(By locator) {
        return DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)).getText();
    }

    public static boolean isElementDisplayed(By locator) {
        try {
            return DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)).isDisplayed();
        } catch (TimeoutException e) {
            return false;
        }
    }

    public static void selectDropdownByVisibleText(By locator, String visibleText) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByVisibleText(visibleText);
    }

    public static void selectDropdownByValue(By locator, String value) {
        Select dropdown = new Select(DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByValue(value);
    }

    public static WebElement waitForElementToBeVisible(By locator){
        return DriverInstance.getWait()
            .until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public static boolean waitForElementToDisappear(By locator){
        return DriverInstance.getWait()
            .until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    public static void scrollToElement(By locator) throws Exception {
        WebElement element = DriverInstance.getDriver().findElement(locator);
        ((JavascriptExecutor) DriverInstance.getDriver()).executeScript("arguments[0].scrollIntoView(true);", element);
    }

    public static void clickWithJS(By locator) throws Exception {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(locator));
        ((JavascriptExecutor) DriverInstance.getDriver()).executeScript("arguments[0].click();", element);
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
}