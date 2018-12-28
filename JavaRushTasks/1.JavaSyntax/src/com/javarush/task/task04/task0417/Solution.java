package com.javarush.task.task04.task0417;

/* 
Существует ли пара?
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

        if (num1 == num2 && num2 == num3)
            System.out.println(num1+" "+num2+" "+num3);
        else if (num1 ==  num2)
            System.out.println(num1+" "+num2);
        else if (num2 ==  num3)
            System.out.println(num2+" "+num3);
        else if (num1 ==  num3)
            System.out.println(num1+" "+num3);
    }
}