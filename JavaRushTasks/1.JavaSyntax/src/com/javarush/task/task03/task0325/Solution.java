package com.javarush.task.task03.task0325;

import java.io.*;

/* 
Финансовые ожидания
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        String ssum = bfreader.readLine();
        int sum = Integer.parseInt(ssum);
        System.out.println("Я буду зарабатывать $"+sum+" в час");
    }
}
