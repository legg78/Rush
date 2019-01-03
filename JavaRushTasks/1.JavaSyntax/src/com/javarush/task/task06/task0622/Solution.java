package com.javarush.task.task06.task0622;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;

/* 
Числа по возрастанию
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        //напишите тут ваш код
        ArrayList<Integer> ar = new ArrayList<Integer>();
        ar.add(Integer.parseInt(reader.readLine()));
        ar.add(Integer.parseInt(reader.readLine()));
        ar.add(Integer.parseInt(reader.readLine()));
        ar.add(Integer.parseInt(reader.readLine()));
        ar.add(Integer.parseInt(reader.readLine()));
        Collections.sort(ar);
        for (Integer ii:ar)
            System.out.println(ii);
    }
}
