package com.javarush.task.task05.task0532;

import java.io.*;

/* 
Задача по алгоритмам
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        int maximum = 0;
        int cnt = Integer.valueOf(reader.readLine());
        boolean flag = true;

        //напишите тут ваш код
        for (int ii =0; ii++<cnt;) {

            int num = Integer.valueOf(reader.readLine());
            if (flag) {maximum=num; flag= false;}
            maximum = maximum < num ? num : maximum;
        }

        System.out.println(maximum);
    }
}
