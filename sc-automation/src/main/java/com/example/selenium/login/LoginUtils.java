package com.example.selenium.login;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class LoginUtils {
    
    public static void Login(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        //login inputs
        WebElement userNameField = wait.until(ExpectedConditions.presenceOfElementLocated(By.name("Ecom_User_ID")));
        WebElement passwordField = wait.until(ExpectedConditions.presenceOfElementLocated(By.name("Ecom_Password")));

        userNameField.sendKeys(System.getenv("LOGIN_USERNAME"));
        passwordField.sendKeys(System.getenv("LOGIN_PASSWORD"));

        //click login
        wait.until(ExpectedConditions.elementToBeClickable(By.name("loginButton2"))).click();
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ Login successful");
    }

    public static void warningBypass(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        try {
            wait.until(ExpectedConditions.titleContains("Form is not secure"));
            WebElement sendAnywayBtn = wait.until(ExpectedConditions.elementToBeClickable(By.id("proceed-button")));
            sendAnywayBtn.click();
        } catch (TimeoutException e) {
            System.out.println("Timeout; no warning messsage page");
        } catch (NoSuchElementException e) {
            System.out.println("No warning message found, proceeding with the test");
        }
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ Bypassed warning page");
    }
}
