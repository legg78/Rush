package com.javarush.task.task04.task0436;


/* 
Рисуем прямоугольник
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
        for (int ii = 0;ii++<num1;) {
            for (int nn = 0;nn++<num2;)
                System.out.print("8");
            System.out.println();
        }
    }
}
