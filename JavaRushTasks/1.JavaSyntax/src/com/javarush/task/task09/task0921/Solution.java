package com.javarush.task.task09.task0921;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/* 
Метод в try..catch
*/

public class Solution {
    public static void main(String[] args) {
        readData();
    }

    public static void readData() {
        //напишите тут ваш код
        BufferedReader rd = new BufferedReader(new InputStreamReader(System.in));
        int num;
        ArrayList<Integer> ar = new ArrayList<>();
        while (true) {
        try {
            num = Integer.valueOf(rd.readLine());
            ar.add(num);
        }
        catch (Exception e) {
            for (Integer nm:ar)
                System.out.println(nm);
            break;
        }}
    }
}
