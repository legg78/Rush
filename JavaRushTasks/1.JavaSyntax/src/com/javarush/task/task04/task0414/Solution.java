package com.javarush.task.task04.task0414;

/* 
Количество дней в году
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        String snum = bfreader.readLine();
        int num = Integer.parseInt(snum);

        if (num%400 == 0)
            System.out.println("количество дней в году: 366");
        else if (num%100 == 0)
            System.out.println("количество дней в году: 365");
        else if (num%4 == 0)
            System.out.println("количество дней в году: 366");
        else
            System.out.println("количество дней в году: 365");
    }
}