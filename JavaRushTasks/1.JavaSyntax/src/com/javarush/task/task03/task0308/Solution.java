package com.javarush.task.task03.task0308;

/* 
Произведение 10 чисел
*/

public class Solution {
    private static int seq_multiples (int length) {
        int res = 1;
        for (int ii = 1; ii <= length; ii++) {
            res *= ii;
        }
        return res;
    }
    public static void main(String[] args) {
        //напишите тут ваш код
      System.out.println(seq_multiples(10));

    }



}
