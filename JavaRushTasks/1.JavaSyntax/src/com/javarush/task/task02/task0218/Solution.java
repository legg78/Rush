package com.javarush.task.task02.task0218;

/* 
Повторенье-мать
*/
public class Solution {
    public static void print3(String s) {
        //напишите тут ваш код
        for (int ii = 0; ii < 3; ii++)
            System.out.println(s);
    }

    public static void main(String[] args) {
        print3("I love you!");
    }
}