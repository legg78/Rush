package com.javarush.task.task07.task0711;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Удалить и вставить
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<String> ar = new ArrayList<>();
        for (int ii=0; ii++<5;)
            ar.add(reader.readLine());
        for (int ii=0; ii++<13;) {
            String str = ar.get(ar.size()-1);
            ar.remove(str);
            ar.add(0,str);

        }
        for (String st:ar)
            System.out.println(st);;
    }



}
