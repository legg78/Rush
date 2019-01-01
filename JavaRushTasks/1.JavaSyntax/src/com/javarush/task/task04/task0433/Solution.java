package com.javarush.task.task04.task0433;


/* 
Гадание на долларовый счет
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        int ii = 0;
        int ss = 0;
        //напишите тут ваш код
        while (ii++<10 ) {
            while (ss++ < 10)
                System.out.print("S");
            System.out.println();
            ss = 0;
        }
    }
}
