package com.javarush.task.task13.task1326;

/* 
Сортировка четных чисел из файла
*/

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.TreeSet;

public class Solution {
    public static void main(String[] args) {
        // напишите тут ваш код
        BufferedReader bf;
        File file;
        String fileName;
        String os;
        BufferedWriter bw;
        FileInputStream fIS;
        ArrayList<Integer> ts = new ArrayList();
        try {
            bf = new BufferedReader(new InputStreamReader(System.in));

            fileName = bf.readLine();
            bf.close();
            file = new File(fileName);
            bf = new BufferedReader(new InputStreamReader(new FileInputStream(file)));

            while (true) {
               os = bf.readLine();
                if (os==null)
                    break;
                else if (Integer.valueOf(os)%2==0&&Integer.valueOf(os)!=0)
                    ts.add(Integer.parseInt(os));
            }

            bf.close();
        } catch (Exception e) {e.printStackTrace();}
        Collections.sort(ts);
        for (Integer ii:ts)
            System.out.println(ii);


    }
}
