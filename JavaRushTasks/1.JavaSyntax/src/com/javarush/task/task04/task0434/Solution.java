package com.javarush.task.task04.task0434;


/* 
Таблица умножения
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        int ii = 0;
        while (ii++<10) {
            int nn = 0;
            while (nn++<10)
                System.out.print(nn*ii+" ");
            System.out.println();
        }
    }
}
