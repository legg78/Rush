package com.javarush.task.task07.task0709;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Выражаемся покороче
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код

        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> strings = new ArrayList<>();
        int maxl=0;
        strings.add(reader.readLine());
        maxl = strings.get(0).length();
        strings.add(reader.readLine());
        strings.add(reader.readLine());
        strings.add(reader.readLine());
        strings.add(reader.readLine());
        for (String str:strings)
            if (str.length()<maxl)
                maxl=str.length();
        for (String str:strings)
            if(str.length()==maxl)
                System.out.println(str);
    }
}
