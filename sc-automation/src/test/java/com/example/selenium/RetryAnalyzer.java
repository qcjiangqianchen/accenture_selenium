package com.example.selenium;

import org.testng.IRetryAnalyzer;
import org.testng.ITestResult;

public class RetryAnalyzer implements IRetryAnalyzer {

    private int retryCount = 0;
    private final int maxRetryCount = 2; // retry up to 2 times

    @Override
    public boolean retry(ITestResult result) {
        if (retryCount < maxRetryCount) {
            retryCount++;
            System.out.println("🔁 Retrying " + result.getName() + " (attempt " + (retryCount + 1) + ")");
            return true;
        }
        return false;
    }
}
