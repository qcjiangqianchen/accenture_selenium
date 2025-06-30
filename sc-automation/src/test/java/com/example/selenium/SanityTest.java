package com.example.selenium;

import org.testng.annotations.Test;
    public class SanityTest {
        @Test(groups = {"Test123"})
        public void sanityCheck() {
            System.out.println("✅ Sanity test is running!");
        }
    }