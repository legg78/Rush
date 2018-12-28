package com.javarush.task.task03.task0319;

/* 
Предсказание на будущее
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(reader);

        String name = bufferedReader.readLine();
        String ssum = bufferedReader.readLine();
        int sum = Integer.parseInt(ssum);
        String sage = bufferedReader.readLine();
        int age = Integer.parseInt(sage);

        System.out.println(name+" получает "+sum+" через "+age+" лет.");
    }
}
