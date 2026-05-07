package com.noahstudio.util;

import java.io.*;
import java.nio.file.*;
import java.util.*;

/**
 * FileHandler — central utility for reading and writing pipe-delimited text files.
 * All data files are stored in the /data/ directory relative to the web-app root.
 * Uses BufferedReader / FileWriter for efficient I/O.
 */
public class FileHandler {

    // ── Resolved data directory (set once at startup via init()) ─────────────
    private static String dataDir = null;

    /**
     * Call this from each servlet's init() with the real filesystem path.
     *   e.g. context.getRealPath("/") + "data/"
     */
    public static void init(String resolvedDataDir) {
        dataDir = resolvedDataDir;
        File dir = new File(dataDir);
        if (!dir.exists()) dir.mkdirs();
    }

    /** Returns the full path for a given filename. */
    public static String getPath(String filename) {
        if (dataDir == null) throw new IllegalStateException("FileHandler not initialised.");
        return dataDir + File.separator + filename;
    }

    // ── Core I/O helpers ─────────────────────────────────────────────────────

    /**
     * Reads all non-blank, non-comment lines from a file.
     * Lines starting with '#' are treated as comments.
     */
    public static List<String> readLines(String filename) throws IOException {
        List<String> lines = new ArrayList<>();
        File file = new File(getPath(filename));
        if (!file.exists()) return lines;          // empty list — file not yet created

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty() && !line.startsWith("#")) {
                    lines.add(line);
                }
            }
        }
        return lines;
    }

    /**
     * Overwrites the file with the supplied list of lines.
     * Each entry is written as its own line.
     */
    public static void writeLines(String filename, List<String> lines) throws IOException {
        File file = new File(getPath(filename));
        file.getParentFile().mkdirs();
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) {
            for (String line : lines) {
                bw.write(line);
                bw.newLine();
            }
        }
    }

    /**
     * Appends a single line to the file (creates it if it does not exist).
     */
    public static void appendLine(String filename, String line) throws IOException {
        File file = new File(getPath(filename));
        file.getParentFile().mkdirs();
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
            bw.write(line);
            bw.newLine();
        }
    }

    /**
     * Deletes a record whose first pipe-separated field matches the given id.
     * Returns true if a record was removed.
     */
    public static boolean deleteById(String filename, String id) throws IOException {
        List<String> lines  = readLines(filename);
        List<String> result = new ArrayList<>();
        boolean found = false;
        for (String line : lines) {
            String lineId = line.split("\\|", 2)[0];
            if (lineId.equals(id)) { found = true; }
            else                   { result.add(line); }
        }
        if (found) writeLines(filename, result);
        return found;
    }

    /**
     * Updates a record whose first field matches id by replacing the whole line.
     * Returns true if updated.
     */
    public static boolean updateById(String filename, String id, String newLine) throws IOException {
        List<String> lines  = readLines(filename);
        List<String> result = new ArrayList<>();
        boolean found = false;
        for (String line : lines) {
            String lineId = line.split("\\|", 2)[0];
            if (lineId.equals(id)) { result.add(newLine); found = true; }
            else                   { result.add(line); }
        }
        if (found) writeLines(filename, result);
        return found;
    }

    /**
     * Finds a single line whose first field equals id. Returns null if not found.
     */
    public static String findById(String filename, String id) throws IOException {
        for (String line : readLines(filename)) {
            if (line.split("\\|", 2)[0].equals(id)) return line;
        }
        return null;
    }

    // ── ID Generation ─────────────────────────────────────────────────────────
    /**
     * Generates a simple sequential ID prefixed by the given prefix.
     * e.g. generateId("USR", "users.txt") → "USR004"
     */
    public static String generateId(String prefix, String filename) throws IOException {
        List<String> lines = readLines(filename);
        return prefix + String.format("%03d", lines.size() + 1);
    }

    // ── Validation helpers ────────────────────────────────────────────────────
    public static boolean isNullOrEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        return email != null && email.matches("^[\\w.+-]+@[\\w-]+\\.[\\w.]+$");
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^[0-9]{7,15}$");
    }

    public static String sanitize(String input) {
        if (input == null) return "";
        return input.replace("|", "~").replace("\n", " ").trim();
    }
}
