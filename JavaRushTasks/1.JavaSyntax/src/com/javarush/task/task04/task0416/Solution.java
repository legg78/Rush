package com.javarush.task.task04.task0416;

/* 
Переходим дорогу вслепую
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        String snum = bfreader.readLine();
        double num1 = Double.parseDouble(snum);


        if (num1%5 < 3)
            System.out.println("зеленый");
        else if (num1%5 <4)
            System.out.println("желтый");
        else
            System.out.println("красный");
    }
}