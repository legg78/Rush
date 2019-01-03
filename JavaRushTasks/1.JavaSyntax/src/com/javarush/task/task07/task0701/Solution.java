package com.javarush.task.task07.task0701;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/* 
Массивный максимум
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        int[] array = initializeArray();
        int max = max(array);
        System.out.println(max);
    }

    public static int[] initializeArray() throws IOException {
        // создай и заполни массив
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        int  ar [] = new int[20] ;
        for (int ii=0;ii<20;ii++)
            ar[ii] = Integer.valueOf(reader.readLine());
        return ar;
    }

    public static int max(int[] array) {
        // найди максимальное значение
        int max = array[0];
        for (int ii:array) {
            System.out.println(ii);
            if (max < ii)
                max = ii;
        }
        return max;
    }
}
