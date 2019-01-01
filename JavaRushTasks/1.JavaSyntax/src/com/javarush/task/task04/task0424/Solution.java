package com.javarush.task.task04.task0424;

/* 
Три числа
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
        String sNum3 = bufferedReader.readLine();
        int num3 = Integer.valueOf(sNum3);

        if (num1 == num2 && num3 != num1)
            System.out.println(3);
        if (num1 == num3 && num3 != num2)
            System.out.println(2);
        if (num3 == num2 && num3 != num1)
            System.out.println(1);
    }
}
