package com.javarush.task.task08.task0821;

import java.util.HashMap;
import java.util.Map;

/* 
Однофамильцы и тёзки
*/

public class Solution {
    public static void main(String[] args) {
        Map<String, String> map = createPeopleList();
        printPeopleList(map);
    }

    public static Map<String, String> createPeopleList() {
        HashMap<String, String> hm = new HashMap<>();
        hm.put("арбуз","ягода");
        hm.put("банан","трава");
        hm.put("вишня","ягода");
        hm.put("груша","фрукт");
        hm.put("вишня","овощ");
        hm.put("ежевика","куст");
        hm.put("жень-шень","корень");
        hm.put("вишня","ягода");
        hm.put("ирис","цветок");
        hm.put("картофель","клубень");
        return hm;
    }

    public static void printPeopleList(Map<String, String> map) {
        for (Map.Entry<String, String> s : map.entrySet()) {
            System.out.println(s.getKey() + " " + s.getValue());
        }
    }
}
