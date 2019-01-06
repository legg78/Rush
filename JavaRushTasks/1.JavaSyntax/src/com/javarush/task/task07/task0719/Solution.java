package com.javarush.task.task07.task0719;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Вывести числа в обратном порядке
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        //напишите тут ваш код

        ArrayList<Integer> list = new ArrayList<>();
        int ln = 0;
        for (int ii=0;ii<10;ii++) {
            list.add(Integer.valueOf(reader.readLine()));
        }
        for (int ii=9;ii>=0;ii--)
            System.out.println(list.get(ii));
    }
}
