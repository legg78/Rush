package com.javarush.task.task15.task1519;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

/* 
Разные методы для разных типов
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        //напиште тут ваш код
        BufferedReader bf  = new BufferedReader((new InputStreamReader(System.in)));
        String str;
        Object ob;
        while (true) {
            str = bf.readLine();
            if (str.equals("exit"))
            {   break;}
        try {ob = Double.parseDouble(str);
        if (str.indexOf('.')!=-1)
            print(Double.valueOf(str));
        else if (Integer.parseInt(str)>0&&Integer.parseInt(str)<128)
            print(Short.valueOf(str));
        else
            print(Integer.parseInt(str));
        }
        catch(Exception e) {
           // e.printStackTrace();
            print(str);
        }
        }
    }

    public static void print(Double value) {
        System.out.println("Это тип Double, значение " + value);
    }

    public static void print(String value) {
        System.out.println("Это тип String, значение " + value);
    }

    public static void print(short value) {
        System.out.println("Это тип short, значение " + value);
    }

    public static void print(Integer value) {
        System.out.println("Это тип Integer, значение " + value);
    }
}
