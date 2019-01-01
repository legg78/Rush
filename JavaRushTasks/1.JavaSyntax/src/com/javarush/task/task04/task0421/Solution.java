package com.javarush.task.task04.task0421;

/* 
Настя или Настя?
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String name1 = bufferedReader.readLine();
        String name2 = bufferedReader.readLine();
        if (name1.equals(name2))
            System.out.println("Имена идентичны");
        else if (name1.length() == name2.length())
            System.out.println( "Длины имен равны");
    }
}
