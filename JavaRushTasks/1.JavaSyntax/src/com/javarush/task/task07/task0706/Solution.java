package com.javarush.task.task07.task0706;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/* 
Улицы и дома
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        int sum1=0;
        int sum2=0;

        int [] nn = new int[15];

        for (int ii=0;ii<nn.length;ii++ )
            nn[ii] = Integer.valueOf(reader.readLine());
        for (int ii=0;ii<nn.length;ii++ ) {
            if (ii%2==0)
                sum2+=nn[ii];
            else
                sum1+=nn[ii];
        }

        if (sum1>sum2)
            System.out.println("В домах с нечетными номерами проживает больше жителей.");
        else
            System.out.println("В домах с четными номерами проживает больше жителей.");

    }
}
