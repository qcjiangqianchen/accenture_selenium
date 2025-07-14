package com.example.selenium.utils;

import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;

public class FileUtils {

    public static Set<String> getFilesBeforeDownload() {
        Path downloadsPath = Paths.get(System.getProperty("user.home"), "Downloads");
        if (downloadsPath.toFile().list()== null) {
            return null;
        }
        return Arrays.stream(downloadsPath.toFile().list()).collect(Collectors.toSet());
    }    

    public static Path waitForNewDownload(Set<String> beforeFiles, int timeoutSeconds) throws Exception {
        Path downloadsPath = Paths.get(System.getProperty("user.home"), "Downloads");

        //waits up to timeoutsecond(approx 2s) to compare the files in Downloads folder to beforefiles
        for (int i=0; i<timeoutSeconds; i++) {
            Set<String> afterFiles = Arrays.stream(downloadsPath.toFile().list()).collect(Collectors.toSet());
            Set<String> newFiles = new HashSet<>(afterFiles);
            newFiles.removeAll(beforeFiles);
            if (!newFiles.isEmpty()) {
                return downloadsPath.resolve(newFiles.iterator().next());
            }
            Thread.sleep(1000); // Wait for 1 second before checking again
        }
        throw new RuntimeException("No new downloads detected");
    }

}
