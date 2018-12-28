package com.javarush.task.task01.task0132;

/* 
Сумма цифр трехзначного числа
*/

public class Solution {
    public static void main(String[] args) {
        System.out.println(sumDigitsInNumber(546));
    }

    public static int sumDigitsInNumber(int number) {
        //напишите тут ваш код
        String nmb = String.valueOf(number);

        return Integer.valueOf(nmb.substring(0,1))+Integer.valueOf(nmb.substring(1,2))+Integer.valueOf(nmb.substring(2,3));
    }
}