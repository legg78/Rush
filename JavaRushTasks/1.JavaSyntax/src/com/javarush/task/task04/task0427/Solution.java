package com.javarush.task.task04.task0427;

/* 
Описываем числа
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        String str;
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String sNum1 = bufferedReader.readLine();
        int num1 = Integer.valueOf(sNum1);
        if (num1>999 || num1 < 1)
            return;
        if (num1%2==0) {
            str ="четное ";
        }
        else str = "нечетное ";
        if (sNum1.length()==1) {
            str += "однозначное";
        } else if (sNum1.length()==2) {
            str += "двузначное";
        } else  {
            str += "трехзначное";
        };

        str+=" число";
        System.out.println(str);
    }
}
