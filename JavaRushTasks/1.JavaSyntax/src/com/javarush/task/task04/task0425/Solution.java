package com.javarush.task.task04.task0425;

/* 
Цель установлена!
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String sNum1 = bufferedReader.readLine();
        int num1 = Integer.valueOf(sNum1);
        String sNum2 = bufferedReader.readLine();
        int num2 = Integer.valueOf(sNum2);
        if (num1 >0)
            if (num2 >0)
                System.out.println(1);
            else
                System.out.println(4);
         else
             if (num2 > 0)
                 System.out.println(2);
             else
                 System.out.println(3);
    }
}
