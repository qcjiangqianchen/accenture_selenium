package com.example.selenium.utils;

import com.example.selenium.driver.DriverInstance;
import com.example.selenium.utils.SeleniumUtils;

import java.util.*;

import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.interactions.Actions;

public class TestCaseUtils {
    public static void filterByLevelAndClass(String levelString, String classString) throws Exception {   
        //navigate to level nav tab
        SeleniumUtils.clickElement(By.xpath("//a[@class='site-menu-btn' and @data-target='#megaMenu-level']"));
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level nav tab accessed");

        //filter by level
        SeleniumUtils.clickElement(By.xpath("//li[contains(@class, 'ng-star-inserted') and contains(text(), '" + levelString + "')]"));
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ level chosen"); 

        //filter by class
        SeleniumUtils.clickElement(By.xpath("//div[contains(@class,'ng-star-inserted') and contains(@class, 'show')]//a[normalize-space(text())='" + classString + "']"));
        Thread.sleep(2000); // Wait for the page to load
        System.out.println("✅ class chosen");
    }

    public static void filterByStudent() {
        
    }
}
    