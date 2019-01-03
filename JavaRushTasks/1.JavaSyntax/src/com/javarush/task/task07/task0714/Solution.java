package com.javarush.task.task07.task0714;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;

/* 
Слова в обратном порядке
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> ar = new ArrayList<>();
        for (int ii=0;ii++<5;)
            ar.add(reader.readLine());
        ar.remove(2);
        for (int ii=ar.size();ii-->0;)
            System.out.println(ar.get(ii));
    }
}


