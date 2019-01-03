package com.javarush.task.task07.task0712;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Самые-самые
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        int max,min,indmin=0,indmax=0;
        boolean flag;
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> ar = new ArrayList<>();
        for (int ii=0; ii++<10;)
            ar.add(reader.readLine());
        max = ar.get(0).length();
        min = max;
        for (String str:ar) {
            if (str.length()>max) {
                max = str.length();
                indmax = ar.indexOf(str);
            }
            if (str.length()<min) {
                min = str.length();
                indmin = ar.indexOf(str);
            }

        }
        if (indmin<indmax)
            System.out.println(ar.get(indmin));
        else
            System.out.println(ar.get(indmax));



    }
}
