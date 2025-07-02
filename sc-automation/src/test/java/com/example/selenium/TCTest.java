package com.example.selenium;

import com.example.selenium.login.LoginUtils;
import com.example.selenium.driver.DriverInstance;
import com.example.selenium.loading.SubjectAllocation;
import com.example.selenium.testcases.TCA1;
import com.example.selenium.testcases.TCA5;
import com.example.selenium.testcases.TCA7;
import com.example.selenium.testcases.TCA11;
import com.example.selenium.testcases.TCA13;
import com.example.selenium.testcases.TCA14;
import com.example.selenium.testcases.TCA15;
import com.example.selenium.testcases.TCA16;

import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Files;

public class TCTest {
    @Test(groups = {"dataPrep"})
    public void dataPrep() throws IOException {
        // === Configuration ===
        String psqlPath = "bin/psql/psql.exe";  // relative to your project root
        String host = "dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com";
        String port = "5432";
        String dbName = "predevscpg_new";
        String username = "predevscpgadmin";
        String password = "password_predevscpgadmin";
        int start_sch = 9808;
        int end_sch = 9808;
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

        for (File sqlFileTemp : sqlFiles) {
            String sqlText = Files.readString(sqlFileTemp.toPath(), StandardCharsets.UTF_8);
            String substituted = sqlText.replace("START_SCH", Integer.toString(start_sch));
            substituted = substituted.replace("END_SCH", Integer.toString(end_sch));
            Path tmp = Files.createTempFile("exec-", "-" + sqlFileTemp.getName());
            Files.writeString(tmp, substituted, StandardCharsets.UTF_8);
            tmp.toFile().deleteOnExit();
            System.out.println("▶️ Executing: " + sqlFileTemp.getName());
            
            ProcessBuilder pb = new ProcessBuilder(
                psqlPath,
                "-h", host,
                "-p", port,
                "-U", username,
                "-d", dbName,
                "-f", tmp.toAbsolutePath().toString()
            );

            pb.environment().put("PGPASSWORD", password);
            pb.inheritIO();

            try {
                Process process = pb.start();
                int exitCode = process.waitFor();
                if (exitCode == 0) {
                    System.out.println("✅ Success: " + sqlFileTemp.getName());
                } else {
                    System.err.println("❌ Failed: " + sqlFileTemp.getName() + " (Exit Code " + exitCode + ")");
                }
            } catch (IOException | InterruptedException e) {
                System.err.println("❌ Error executing " + sqlFileTemp.getName() + ": " + e.getMessage());
                e.printStackTrace();
            }
        }
        System.out.println("✅ All scripts executed.");
    }

    @Test(groups = {"dataDelete"})
    public void dataDelete() {
        //run the delete scripts after all tests cases are executed to ensure that data is cleared
        // Configurations
        String psqlPath = "bin/psql/psql.exe";  // relative to your project root
        String host = "dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com";
        String port = "5432";
        String dbName = "predevscpg_new";
        String username = "predevscpgadmin";
        String password = "password_predevscpgadmin";
        System.out.println("Data deleted from pipline");

        String folderPath = "dataDelete";  // Adjust if needed
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

    @Test(groups = {"loginAndBypass"})
    public void prepareEnvironment(WebDriver driver, WebDriverWait wait) throws InterruptedException { 
        // Landing page + login
        driver.manage().window().maximize();   //Mazimize current window
        driver.get("http://predev.schoolcockpit.local.sc/academic/results-by-subject/SEC1-01");
        LoginUtils.Login(driver, wait);
        LoginUtils.warningBypass(driver, wait);
    }

    @Test(groups = {"subjectAllocation"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runSubjectAllocation() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            SubjectAllocation subjectAllocation = new SubjectAllocation();
            subjectAllocation.run(driver, wait);
        } finally {
            if (driver != null) {
                DriverInstance.quitDriver(); 
            }
        }
    }

    @Test(groups = {"tca1", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA1() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA1 tca1 = new TCA1();
            tca1.run(driver, wait);
        } finally {
            DriverInstance.quitDriver();
        }
    }

    @Test(groups = {"tca5", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA5() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA5 tca5 = new TCA5();
            tca5.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                DriverInstance.quitDriver(); // ✅ always clean up
            }
        }
    }

    @Test(groups = {"tca7", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA7() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA7 tca7 = new TCA7();
            tca7.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                DriverInstance.quitDriver(); // ✅ always clean up
            }
        }
    }

    @Test(groups = {"tca11", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA11Test() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        System.out.println("✅ Test is running!");
        try {
            prepareEnvironment(driver, wait);
            TCA11 tca11 = new TCA11();
            tca11.run(driver, wait);
        } catch (Exception e) {
            throw new RuntimeException(e); // rethrow so RetryAnalyzer kicks in
        } finally {
            if (driver != null) {
                DriverInstance.quitDriver(); // ✅ always clean up
            }
        }
    }

    @Test(groups = {"tca13", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA13() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA13 tca13 = new TCA13();
            tca13.run(driver, wait);
        } finally {
            DriverInstance.quitDriver();
        }
    }

    @Test(groups = {"tca14", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA14() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA14 tca14 = new TCA14();
            tca14.run(driver, wait);
        } finally {
            DriverInstance.quitDriver();
        }
    }

    @Test(groups = {"tca15", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA15() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA15 tca15 = new TCA15();
            tca15.run(driver, wait);
        } finally {
            DriverInstance.quitDriver();
        }
    }

    @Test(groups = {"tca16", "SEC"}, retryAnalyzer = com.example.selenium.RetryAnalyzer.class)
    public void runTCA16() throws Exception {
        WebDriver driver = DriverInstance.getDriver();
        WebDriverWait wait = DriverInstance.getWait();
        try {
            prepareEnvironment(driver, wait);
            TCA16 tca16 = new TCA16();
            tca16.run(driver, wait);
        } finally {
            DriverInstance.quitDriver();
        }
    }
    @AfterMethod
    public void tearDown() {
        DriverInstance.quitDriver();
    }
}
