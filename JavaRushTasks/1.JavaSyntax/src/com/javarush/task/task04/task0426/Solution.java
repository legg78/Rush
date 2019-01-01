package com.javarush.task.task04.task0426;

/* 
Ярлыки и числа
*/

import java.io.*;

public class Solution {    int a;
    int b;
    public static void main(String[] args) throws Exception {

        String str;
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String sNum1 = bufferedReader.readLine();
        int num1 = Integer.valueOf(sNum1);
        if (num1 == 0)
            str="ноль";
        else {
        if (num1>0) {
            str="положительное ";
        }
        else  {
            str="отрицательное ";
        }
        if (num1%2==0)
            str+="четное ";
        else
            str+="нечетное ";
        str+="число";
        }
        System.out.println(str);

    }

}
