package com.javarush.task.task04.task0442;


/* 
Суммирование
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        int num1, num = 0;
        String snum;
        while (true) {
            snum = bfreader.readLine();
            num1 = Integer.parseInt(snum);
            num +=num1;
            if (num1 == -1) {
                System.out.println(num);
                break;
            }
        }
    }
}
