package com.javarush.task.task08.task0815;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;

/* 
Перепись населения
*/

public class Solution {
    public static HashMap<String, String> createMap() {
        //напишите тут ваш код
        HashMap<String,String> hm = new HashMap<>();
        hm.put("f1","n1");
        hm.put("f2","n1");
        hm.put("f3","n1");
        hm.put("f4","n2");
        hm.put("f5","n3");
        hm.put("f6","n3");
        hm.put("f7","n2");
        hm.put("f8","n2");
        hm.put("f9","n2");
        hm.put("f51","n2");
        return hm;
    }

    public static int getCountTheSameFirstName(HashMap<String, String> map, String name) {


        //напишите тут ваш код
        int cnt=0;
        for (String c : map.values()) {
            if (c.equals(name))
                cnt++;

        }
        return cnt;
    }

    public static int getCountTheSameLastName(HashMap<String, String> map, String lastName) {
        //напишите тут ваш код
        if (map.containsKey(lastName))

            return 1;
        else return 0;
    }

    public static void main(String[] args) {

    }
}
