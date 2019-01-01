package com.javarush.task.task04.task0428;

/* 
Положительное число
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
        int cnt = 0;
        if (num1 > 0)
            cnt++;
        if (num2 > 0)
            cnt++;
        if (num3 > 0)
            cnt++;
        System.out.println(cnt);


    }
}
