package com.javarush.task.task07.task0718;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Проверка на упорядоченность
*/
public class Solution {
    public static void main(String[] args) throws IOException {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> list = new ArrayList<>();
        int ln = 0;
        for (int ii=0;ii<10;ii++) {
            list.add(reader.readLine());
        }
        for (String str:list)
            if (str.length()>=ln)
                ln=str.length();
            else {
                System.out.println(list.indexOf(str));
                break;
            }
    }
}

