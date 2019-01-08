package com.javarush.task.task08.task0830;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/* 
Задача по алгоритмам
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String[] array = new String[20];
        for (int i = 0; i < array.length; i++) {
            array[i] = reader.readLine();
        }

        sort(array);

        for (String x : array) {
            System.out.println(x);
        }
    }

    public static void sort(String[] array) {
        //напишите тут ваш код
        for (int ii = 1;ii<array.length;ii++) {
        ////    System.out.println("bc str "+array[ii]);
            String tm = array[ii];
            for (int nn = ii-1;nn>=0;nn--) {

            //    System.out.println("   chk "+tm+" "+array[nn]);
                if (isGreaterThan(array[nn],tm)) {
             //       System.out.println("      rep "+tm+" "+array[nn]);

                 array[nn+1] = array [nn];
                 array[nn] = tm;

                }
                else
                    break;
            }
        }
    }

    //Метод для сравнения строк: 'а' больше чем 'b'
    public static boolean isGreaterThan(String a, String b) {
        return a.compareTo(b) > 0;
    }
}
