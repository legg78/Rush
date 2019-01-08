package com.javarush.task.task08.task0817;

import java.util.HashMap;
import java.util.Map;

/* 
Нам повторы не нужны
*/

public class Solution {
    public static HashMap<String, String> createMap() {
        //напишите тут ваш код
        HashMap<String, String> hm = new HashMap<>();
        hm.put("арбуз","ягода");
        hm.put("банан","трава");
        hm.put("вишня","ягода");
        hm.put("груша","фрукт");
        hm.put("дыня","овощ");
        hm.put("ежевика","куст");
        hm.put("жень-шень","корень");
        hm.put("земляника","ягода");
        hm.put("ирис","цветок");
        hm.put("картофель","клубень");
        return hm;
    }

    public static void removeTheFirstNameDuplicates(Map<String, String> map) {
        //напишите тут ваш код
        HashMap<String,String> cl = new HashMap<>(map);
        HashMap<String,String> cl2 = new HashMap<>(map);

            for (Map.Entry<String,String> str:cl2.entrySet()) {
                int cn =0;
                for (Map.Entry<String,String> st:cl.entrySet())
                    if (st.getValue().equals(str.getValue())) {
                       cn++;
                       if (cn>1)
                           removeItemFromMapByValue(map, str.getValue());

                    }
            }



    }

    public static void removeItemFromMapByValue(Map<String, String> map, String value) {
        HashMap<String, String> copy = new HashMap<String, String>(map);
        for (Map.Entry<String, String> pair : copy.entrySet()) {
            if (pair.getValue().equals(value))
                map.remove(pair.getKey());
        }
    }

    public static void main(String[] args) {

    }
}
