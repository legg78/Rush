package com.javarush.task.task07.task0702;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/* 
Массив из строчек в обратном порядке
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String [] ar = new String[10];
        for (int ii =0;ii<8;ii++)
            ar[ii]=reader.readLine();
        for (int ii =9;ii>=0;ii--)
            System.out.println(ar[ii]);

    }
}