package com.javarush.task.task03.task0314;

/* 
Таблица умножения
*/

public class Solution {
    public static void main(String[] args) {
        //напишите тут ваш код
        for (int ii = 1; ii <= 10; ii++) {
            for (int nn = 1; nn <= 10; nn++)
               if (nn==10)
                  System.out.println(nn*ii);
               else
                  System.out.print(nn*ii+" ");
        }
    }
}
