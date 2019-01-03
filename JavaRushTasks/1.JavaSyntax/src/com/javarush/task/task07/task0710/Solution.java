package com.javarush.task.task07.task0710;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
В начало списка
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> str= new ArrayList<String>();
        for (int ii=0;ii++<10;)
            str.add(0,reader.readLine());
        for (String st:str)
            System.out.println(st);

    }
}
