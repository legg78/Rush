package com.javarush.task.task04.task0419;

/* 
Максимум четырех чисел
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
        snum = bfreader.readLine();
        int num4 = Integer.parseInt(snum);

        if (num1>num2)
        num2=num1;
        if (num3>num4)
            num4=num3;
        if (num2>num4)
            num4=num2;
        System.out.println(num4);
    }
}
