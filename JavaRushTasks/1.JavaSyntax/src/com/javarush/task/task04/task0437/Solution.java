package com.javarush.task.task04.task0437;


/* 
Треугольник из восьмерок
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код

        for (int ii = 0;ii++<10;) {
            for (int nn = 0; nn++ < ii; )
                System.out.print(8);
            System.out.println();
        }
    }
}
