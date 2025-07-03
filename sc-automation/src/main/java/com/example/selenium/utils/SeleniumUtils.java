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
        List <WebElement> nav_btns = DriverInstance.getWait().until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("a.site-menu-btn")));
        WebElement btn = nav_btns.get(1);
        btn.click();
        Thread.sleep(1000); // Wait for the page to load

        //menu to go to results by class
        WebElement page_btn = DriverInstance.getWait().until(ExpectedConditions.elementToBeClickable(By.xpath(desiredPage)));
        page_btn.click();
        Thread.sleep(2000); // Wait for the page to load

        System.out.println("✅ Navigated to Results by Class page");
    }

    public static void typeText(By locator, String text) {
        WebElement element = DriverInstance.getWait().until(ExpectedConditions.visibilityOfElementLocated(locator));
        element.clear();
        element.sendKeys(text);
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

    public static void waitForElementToBeVisible(By locator, int timeoutSeconds) throws Exception {
        new WebDriverWait(DriverInstance.getDriver(), Duration.ofSeconds(timeoutSeconds))
            .until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public static void waitForElementToDisappear(By locator, int timeoutSeconds) throws Exception {
        new WebDriverWait(DriverInstance.getDriver(), Duration.ofSeconds(timeoutSeconds))
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
}