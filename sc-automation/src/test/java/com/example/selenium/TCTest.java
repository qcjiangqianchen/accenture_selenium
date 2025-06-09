package com.example.selenium;

import com.example.selenium.login.LoginUtils;
import com.example.selenium.testcases.TCA1;
import com.example.selenium.testcases.TCA5;
import com.example.selenium.testcases.TCA7;
import com.example.selenium.testcases.TCA11;
import com.example.selenium.testcases.TCA13;
import com.example.selenium.testcases.TCA14;
import com.example.selenium.testcases.TCA15;
import com.example.selenium.testcases.TCA16;

import org.testng.annotations.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.time.Duration;
import java.io.File;
import java.io.IOException;


public class TCTest {
    public static void DataPrep() {
        // === Configuration ===
        String psqlPath = "bin/psql/psql.exe";  // relative to your project root
        String host = "dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com";
        String port = "5432";
        String dbName = "predevscpg_new";
        String username = "predevscpgadmin";
        String password = "password_predevscpgadmin";

        String folderPath = "dataPrep";  // Adjust if needed
        File folder = new File(folderPath);

        if (!folder.exists() || !folder.isDirectory()) {
            System.err.println("❌ Folder not found: " + folderPath);
            return;
        }

        File[] sqlFiles = folder.listFiles((dir, name) -> name.toLowerCase().endsWith(".sql"));

        if (sqlFiles == null || sqlFiles.length == 0) {
            System.out.println("⚠️ No SQL files found in: " + folderPath);
            return;
        }

        // Sort by leading number in filename, then alphabetically
        Arrays.sort(sqlFiles, new Comparator<File>() {
            Pattern pattern = Pattern.compile("^(\\d+)");
            @Override
            public int compare(File f1, File f2) {
                Integer num1 = extractLeadingNumber(f1.getName());
                Integer num2 = extractLeadingNumber(f2.getName());

                if (num1 != null && num2 != null) {
                    return num1.compareTo(num2);
                } else if (num1 != null) {
                    return -1; // Numbers come before non-numbers
                } else if (num2 != null) {
                    return 1;
                } else {
                    return f1.getName().compareTo(f2.getName());
                }
            }

            private Integer extractLeadingNumber(String filename) {
                Matcher matcher = pattern.matcher(filename);
                if (matcher.find()) {
                    try {
                        return Integer.parseInt(matcher.group(1));
                    } catch (NumberFormatException e) {
                        return null;
                    }
                }
                return null;
            }
        });

        for (File sqlFile : sqlFiles) {
            System.out.println("▶️ Executing: " + sqlFile.getName());

            ProcessBuilder pb = new ProcessBuilder(
                psqlPath,
                "-h", host,
                "-p", port,
                "-U", username,
                "-d", dbName,
                "-f", sqlFile.getAbsolutePath()
            );

            pb.environment().put("PGPASSWORD", password);
            pb.inheritIO();

            try {
                Process process = pb.start();
                int exitCode = process.waitFor();
                if (exitCode == 0) {
                    System.out.println("✅ Success: " + sqlFile.getName());
                } else {
                    System.err.println("❌ Failed: " + sqlFile.getName() + " (Exit Code " + exitCode + ")");
                }
            } catch (IOException | InterruptedException e) {
                System.err.println("❌ Error executing " + sqlFile.getName() + ": " + e.getMessage());
                e.printStackTrace();
            }
        }

        System.out.println("✅ All scripts executed.");
    }
    private WebDriver setupDriver() throws InterruptedException {
        DataPrep();
        EdgeOptions options = new EdgeOptions();
        HashMap<String, Object> prefs = new HashMap<>();
        prefs.put("download.default_directory", "C:\\Users\\qianchen.jiang\\Downloads");
        prefs.put("download.prompt_for_download", false);
        prefs.put("safebrowsing.enabled", true);
        options.setExperimentalOption("prefs", prefs);
        return new EdgeDriver(options);
    }

    private void prepareEnvironment(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        // Landing page + login
        driver.manage().window().maximize();   //Mazimize current window
        driver.get("http://predev.schoolcockpit.local.sc/academic/results-by-subject/SEC1-01");
        LoginUtils.Login(driver, wait);
        LoginUtils.warningBypass(driver, wait);
    }

    @Test(groups = {"tca1"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA1() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA1.run(driver, wait);
        } finally {
            driver.quit();
        }
    }
    @Test(groups = {"tca7"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA7() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA7.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }
    @Test(groups = {"tca5"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA5() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA5.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }
    @Test(groups = {"tca11"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA11() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA11.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                driver.quit(); // ✅ always clean up
            }
        }
    }

    @Test(groups = {"tca13"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA13() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA13.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca14"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA14() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA14.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca15"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA15() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA15.run(driver, wait);
        } finally {
            driver.quit();
        }
    }

    @Test(groups = {"tca16"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA16() throws Exception {
        WebDriver driver = setupDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(15));
        try {
            prepareEnvironment(driver, wait);
            TCA16.run(driver, wait);
        } finally {
            driver.quit();
        }
    }
}
