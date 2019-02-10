package com.javarush.task.task13.task1318;

import java.io.*;
import java.util.Scanner;

/* 
Чтение файла
*/

public class Solution {
    public static void main(String[] args) {
        // напишите тут ваш код
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String fileName="";
        try {
            fileName = bf.readLine();
            bf.close();
        }
        catch (IOException e) {

        }
        FileInputStream fIS;
        try {fIS = new FileInputStream(fileName);
        while (fIS.available()>0)
            System.out.print((char)fIS.read());
        fIS.close();
        } catch (IOException e) {}

    }
}