package com.javarush.task.task09.task0922;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/* 
Какое сегодня число?
*/

public class Solution {

    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String sdt = bf.readLine();
        SimpleDateFormat smp = new SimpleDateFormat("yyyy-MM-dd");
        Date dt = smp.parse(sdt);
        SimpleDateFormat smp2 = new SimpleDateFormat("MMM dd, yyyy", Locale.US);
        System.out.println(smp2.format(dt).toUpperCase());
    }
}
