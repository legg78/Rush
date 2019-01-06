package com.javarush.task.task07.task0720;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Перестановочка подоспела
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        //напишите тут ваш код
        ArrayList<String> list = new ArrayList<>();
        int n1,n2;
        n1 = Integer.valueOf(reader.readLine());
        n2 = Integer.valueOf(reader.readLine());
        for (int ii=0;ii++<n1;) {
            list.add(reader.readLine());
        }

        for (int ii=0;ii++<n2;) {
            String str = list.get(0);
            list.remove(0);
            list.add(str);
        }
        for (String str:list)
            System.out.println(str);
    }
}
