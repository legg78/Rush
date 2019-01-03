package com.javarush.task.task07.task0704;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/* 
Переверни массив
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        int [] nn = new int[10];
        for (int ii=0;ii<10;ii++ )
            nn[ii] = Integer.valueOf(reader.readLine());
        for (int ii=9;ii>=0;ii-- )
            System.out.println(nn[ii]);
    }
}

