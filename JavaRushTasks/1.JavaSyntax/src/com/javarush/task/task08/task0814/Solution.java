package com.javarush.task.task08.task0814;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/* 
Больше 10? Вы нам не подходите
*/

public class Solution {
    public static HashSet<Integer> createSet() {
        // напишите тут ваш код
        HashSet<Integer> hs = new HashSet<>();
        hs.add(1);
        hs.add(2);
        hs.add(3);
        hs.add(4);
        hs.add(5);
        hs.add(6);
        hs.add(7);
        hs.add(8);
        hs.add(9);
        hs.add(10);
        hs.add(11);
        hs.add(12);
        hs.add(13);
        hs.add(14);
        hs.add(15);
        hs.add(16);
        hs.add(17);
        hs.add(18);
        hs.add(19);
        hs.add(20);
        return hs;


    }

    public static HashSet<Integer> removeAllNumbersGreaterThan10(HashSet<Integer> set) {
        // напишите тут ваш код
        set.removeIf(p-> p>10);
        return set;

    }

    public static void main(String[] args) {

    }
}
