package com.javarush.task.task04.task0420;

/* 
Сортировка трех чисел
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

        int num;
        if (num1<num2) {
            num = num2;
            num2 = num1;
            num1 = num;
        }
        if (num2<num3) {
            num = num3;
            num3 = num2;
            num2 = num;
            if (num1<num2) {
                num = num2;
                num2 = num1;
                num1 = num;
            }
        }
        System.out.println(num1+" "+num2+" "+num3);
    }
}
