package com.javarush.task.task04.task0422;

/* 
18+
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String name = bufferedReader.readLine();
        String sAge = bufferedReader.readLine();
        int age = Integer.valueOf(sAge);
        if (age < 18)
            System.out.println("Подрасти еще");

    }
}
