package com.example.selenium.login;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.example.selenium.utils.SeleniumUtils;

public class LoginUtils {
    
    public static void Login(WebDriver driver) throws Exception {
        //login inputs
        
        if ("true".equalsIgnoreCase(System.getenv("CI")))
        {
            SeleniumUtils.typeText(By.name("Ecom_User_ID"), System.getenv("LOGIN_USERNAME"), false);
            SeleniumUtils.typeText(By.name("Ecom_Password"), System.getenv("LOGIN_PASSWORD"), false);
        }
        else
        {
            SeleniumUtils.typeText(By.name("Ecom_User_ID"), "SCU00014@schools.gov.sg", false);
            SeleniumUtils.typeText(By.name("Ecom_Password"), "Netiq000!1234", false);
        }
        //click login
        SeleniumUtils.clickElement(By.name("loginButton2"));
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ Login successful");
    }

    public static void warningBypass(WebDriver driver) throws Exception {
        // try {
        //     wait.until(ExpectedConditions.titleContains("Form is not secure"));
        //     SeleniumUtils.clickElement(By.id("proceed-button"));
        // } catch (TimeoutException e) {
        //     System.out.println("Timeout; no warning messsage page");
        // } catch (NoSuchElementException e) {
        //     System.out.println("No warning message found, proceeding with the test");
        // }
        SeleniumUtils.waitForElementToBeVisible(By.id("proceed-button"));
        SeleniumUtils.clickElement(By.id("proceed-button"));
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ Bypassed warning page");
    }
}
