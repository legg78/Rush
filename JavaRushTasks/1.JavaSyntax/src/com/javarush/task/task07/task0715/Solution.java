package com.javarush.task.task07.task0715;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Продолжаем мыть раму
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        ArrayList<String> str = new ArrayList<>();
        int ind = 0;
        str.add("мама");
        str.add("мыла");
        str.add("раму");
        while (true && str.size() != 0) {
        str.add(ind + 1, "именно");
        if (ind + 2 == str.size())
            break;
        else
            ind += 2;
        }
        for (String st:str)
            System.out.println(st);

    }
}
