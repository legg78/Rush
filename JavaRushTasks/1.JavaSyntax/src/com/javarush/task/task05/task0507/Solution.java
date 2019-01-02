package com.javarush.task.task05.task0507;

/* 
Среднее арифметическое
*/

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        int num1,  cnt = 0;
        double num = 0;
        String snum;
        while (true) {
            snum = bfreader.readLine();
            num1 = Integer.parseInt(snum);

            if (num1 == -1) {
                System.out.println(1.0*num/cnt);
                break;
            }
            else {
                num +=num1;
                cnt++;
            }
        }
    }
}

