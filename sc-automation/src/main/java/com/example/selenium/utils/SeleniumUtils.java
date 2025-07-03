package com.example.selenium.utils;

import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.nio.file.*;
import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.example.selenium.driver.DriverInstance;

import dev.failsafe.internal.util.Assert;


public class SeleniumUtils{

    WebDriver driver = null;
    WebDriverWait wait = null;
    public SeleniumUtils() throws MalformedURLException, URISyntaxException 
    {
        driver = DriverInstance.getDriver();
        wait = DriverInstance.getWait();
    }
    public void clickElement(By locator) {
        wait.until(ExpectedConditions.elementToBeClickable(locator)).click();
    }

    public void typeText(By locator, String text) {
        WebElement element = wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
        element.clear();
        element.sendKeys(text);
    }

    public String getText(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator)).getText();
    }

    public boolean isElementDisplayed(By locator) {
        try {
            return wait.until(ExpectedConditions.visibilityOfElementLocated(locator)).isDisplayed();
        } catch (TimeoutException e) {
            return false;
        }
    }
    public void selectDropdownByVisibleText(By locator, String visibleText) {
        Select dropdown = new Select(wait.until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByVisibleText(visibleText);
    }

    public void selectDropdownByValue(By locator, String value) {
        Select dropdown = new Select(wait.until(ExpectedConditions.visibilityOfElementLocated(locator)));
        dropdown.selectByValue(value);
    }
    public void waitForElementToBeVisible(By locator, int timeoutSeconds) {
        new WebDriverWait(driver, Duration.ofSeconds(timeoutSeconds))
            .until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    public void waitForElementToDisappear(By locator, int timeoutSeconds) {
        new WebDriverWait(driver, Duration.ofSeconds(timeoutSeconds))
            .until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }
    public void scrollToElement(By locator) {
        WebElement element = driver.findElement(locator);
        ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", element);
    }

    public void clickWithJS(By locator) {
        WebElement element = wait.until(ExpectedConditions.elementToBeClickable(locator));
        ((JavascriptExecutor) driver).executeScript("arguments[0].click();", element);
    }
}