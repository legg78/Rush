package com.javarush.task.task04.task0415;

/* 
Правило треугольника
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        String snum = bfreader.readLine();
        int num1 = Integer.parseInt(snum);
        snum = bfreader.readLine();
        int num2 = Integer.parseInt(snum);
        snum = bfreader.readLine();
        int num3 = Integer.parseInt(snum);

        if (( num1 + num2 )<= num3 || ( num3 + num2 )<= num1 || ( num1 + num3 )<= num2 )
            System.out.println("Треугольник не существует.");
        else
            System.out.println("Треугольник существует.");
    }
}