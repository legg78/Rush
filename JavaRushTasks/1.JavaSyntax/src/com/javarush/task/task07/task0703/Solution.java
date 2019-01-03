package com.javarush.task.task07.task0703;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/* 
Общение одиноких массивов
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String [] str = new String [10];
        Integer [] nn = new Integer[10];
        for (int ii=0;ii<10;ii++ )
            str[ii] = reader.readLine();

        for (int ii=0;ii<10;ii++ ) {
            nn[ii] = str[ii].length();
            System.out.println(nn[ii]);
        }

    }
}
