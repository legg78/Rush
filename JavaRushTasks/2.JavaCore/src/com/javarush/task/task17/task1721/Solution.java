package com.javarush.task.task17.task1721;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/* 
Транзакционность
*/

public class Solution {
    public static List<String> allLines = new ArrayList<String>();
    public static List<String> forRemoveLines = new ArrayList<String>();

    public static void main(String[] args) {
        try { BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
            allLines = Files.readAllLines(Paths.get(bf.readLine()));
            forRemoveLines = Files.readAllLines(Paths.get(bf.readLine()));

            Solution solution = new Solution();
            solution.joinData(); }
        catch(Exception e) {}
    }

    public void joinData() throws CorruptedDataException {
        boolean isRem = false;

        if (allLines.containsAll(forRemoveLines))
            allLines.removeAll(forRemoveLines);
        else {
            allLines.clear();
throw  new CorruptedDataException();
        }

    }
}
