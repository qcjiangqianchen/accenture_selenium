package com.example.selenium.setup;

import java.util.*;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;



public class TCASetup {
    
    public static void navigateToDesiredPage(WebDriver driver, WebDriverWait wait, String desiredPage) throws InterruptedException{
        //nav btns at top of page
        List <WebElement> nav_btns = wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(By.cssSelector("a.site-menu-btn")));
        WebElement btn = nav_btns.get(1);
        btn.click();
        Thread.sleep(1000); // Wait for the page to load

        //menu to go to results by class
        WebElement page_btn = wait.until(ExpectedConditions.elementToBeClickable(By.xpath(desiredPage)));
        page_btn.click();
        Thread.sleep(2000); // Wait for the page to load

        System.out.println("✅ Navigated to Results by Class page");
    }
}
