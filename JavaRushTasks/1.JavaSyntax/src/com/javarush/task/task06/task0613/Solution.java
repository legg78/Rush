package com.javarush.task.task06.task0613;

/* 
Кот и статика
*/

public class Solution {
    public static void main(String[] args) {
        // Создай 10 котов
        for (int ii=0;ii++<10;)
            new Cat();
        System.out.println(Cat.catCount);
        // Выведи значение переменной catCount
    }

    public static class Cat {
        // Создай статическую переменную catCount
        public static int catCount = 0;
        // Создай конструктор

        public Cat() {
            Cat.catCount++;
        }
    }
}
