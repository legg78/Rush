package com.javarush.task.task13.task1319;

import java.io.*;

/* 
Писатель в файл с консоли
*/

public class Solution {
    public static void main(String[] args) {
        // напишите тут ваш код
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String fileName="";
        BufferedWriter bw;
        String str;
        try {
        fileName = bf.readLine();
        bw = new BufferedWriter(new FileWriter(new File(fileName)));
        while (true) {
             str = bf.readLine();
             bw.write(str);
             bw.newLine();
             if (str.equals("exit"))
                 break;
        }
        bf.close();
        bw.close();} catch (IOException e) {
            int c=1;
        }
    }
}
