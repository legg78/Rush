package com.javarush.task.task07.task0705;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/* 
Один большой массив и два маленьких
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        int [] nn = new int[20];
        int [] nn1 = new int[10];
        int [] nn2 = new int[10];
        for (int ii=0;ii<nn.length;ii++ )
            nn[ii] = Integer.valueOf(reader.readLine());
        for (int ii=0;ii<nn.length;ii++ ) {

            if (ii < nn1.length )
                nn1[ii] = nn[ii];
            else
                nn2[ii - nn1.length] = nn[ii];
        }

        for (int ii=0;ii<nn2.length;ii++ )
            System.out.println(nn2[ii]);
    }
}
