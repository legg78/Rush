package com.javarush.task.task15.task1529;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/* 
Осваивание статического блока
*/

public class Solution  {
    public static void main(String[] args) {

    }
    
    static {
        //add your code here - добавьте код тут
        try {
            reset();
        } catch (Exception e) {}
    }

    public static CanFly result;

    public static void reset() throws Exception {
        //add your code here - добавьте код тут
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String st = bf.readLine();
        if (st.equals("helicopter"))
            result = new Helicopter();
        else if (st.equals("plane")) {
            int nn = Integer.valueOf(bf.readLine());
            result = new Plane(nn);
        }
    };
}
