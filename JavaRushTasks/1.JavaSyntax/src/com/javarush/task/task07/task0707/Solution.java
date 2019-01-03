package com.javarush.task.task07.task0707;

import java.util.ArrayList;

/* 
Что за список такой?
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        ArrayList<String> ar = new ArrayList<>();
        ar.add("1");
        ar.add("1");
        ar.add("1");
        ar.add("1");
        ar.add("1");
        System.out.println(ar.size());
        for (String ss:ar)
            System.out.println(ss);
    }
}
