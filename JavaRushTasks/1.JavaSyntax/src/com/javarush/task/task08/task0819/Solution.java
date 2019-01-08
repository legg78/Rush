package com.javarush.task.task08.task0819;

import java.security.KeyStore;
import java.util.HashSet;
import java.util.Set;

/* 
Set из котов
*/

public class Solution {
    public static class Cat  {

    };
    public static void main(String[] args) {
        Set<Cat> cats = createCats();
        Cat cat = new Cat();

        //напишите тут ваш код. step 3 - пункт 3
        for (Cat ct:cats) {
            cat =ct;
            break;
        }
        cats.remove(cat)    ;
        printCats(cats);
    }

    public static Set<Cat> createCats() {
        //напишите тут ваш код. step 2 - пункт 2
        HashSet<Cat> cats = new HashSet<>();
        cats.add(new Cat());
        cats.add(new Cat());
        cats.add(new Cat());
        return cats;
    }

    public static void printCats(Set<Cat> cats) {
        // step 4 - пункт 4
        cats.forEach(System.out::println);
    }

    // step 1 - пункт 1
}
