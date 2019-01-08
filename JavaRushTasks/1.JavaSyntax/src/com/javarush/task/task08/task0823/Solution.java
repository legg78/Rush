package com.javarush.task.task08.task0823;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/*
Омовение Рамы
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String s = reader.readLine();
        //напишите тут ваш код

        char[] ar = s.toCharArray();
        for(int ii=0;ii<ar.length;ii++)
            if (ii==0)
                ar[ii] = Character.toUpperCase(ar[ii]);
            else if (ar[ii-1]==' ')
                ar[ii] = Character.toUpperCase(ar[ii]);
        s = String.copyValueOf(ar);
        System.out.println(s);
    }
}
