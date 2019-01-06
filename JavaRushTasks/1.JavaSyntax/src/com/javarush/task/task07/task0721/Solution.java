package com.javarush.task.task07.task0721;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/* 
Минимаксы в массивах
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        int maximum;
        int minimum;

        //напишите тут ваш код
        int mm[] = new int[20];
        for (int ii=0;ii< mm.length;ii++)
            mm[ii]=Integer.valueOf(reader.readLine());
        maximum = mm[0];
        minimum = mm[0];
        for (int ii=0;ii< mm.length;ii++) {
            if (maximum < mm[ii])
                maximum = mm[ii];
            if (minimum > mm[ii])
                minimum = mm[ii];
        }

        System.out.print(maximum + " " + minimum);
    }
}
