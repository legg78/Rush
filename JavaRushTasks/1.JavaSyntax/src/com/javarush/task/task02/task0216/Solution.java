package com.javarush.task.task02.task0216;

//import  com.javarush.task.task02.task0214.Solution;

/* 
Минимум трёх чисел
*/
public class Solution {
    public static int min(int a, int b, int c) {
        //напишите тут ваш код
        return (a<b)?((a<c)?a:c):((b<c)?b:c);
    }

    public static void main(String[] args) throws Exception {
        System.out.println(min(1, 2, 3));
        System.out.println(min(-1, -2, -3));
        System.out.println(min(3, 5, 3));
        System.out.println(min(5, 5, 10));
    }

}