package com.javarush.task.task08.task0818;

import java.util.HashMap;
import java.util.Map;

/* 
Только для богачей
*/

public class Solution {
    public static HashMap<String, Integer> createMap() {
        //напишите тут ваш код
        HashMap<String, Integer> hm = new HashMap<>();
        hm.put("арбуз",1);
        hm.put("банан",200);
        hm.put("вишня",300);
        hm.put("груша",400);
        hm.put("дыня",500);
        hm.put("ежевика",600);
        hm.put("жень-шень",700);
        hm.put("земляника",800);
        hm.put("ирис",900);
        hm.put("картофель",10000);
        return hm;
    }

    public static void removeItemFromMap(HashMap<String, Integer> map) {
        //напишите тут ваш код
        map.entrySet().removeIf(entry->entry.getValue()<500);
    }

    public static void main(String[] args) {

    }
}