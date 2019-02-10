package com.javarush.task.task14.task1420;

/* 
НОД
*/

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Solution {
    public static void main(String[] args) throws Exception {
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        Integer n1 = Integer.parseInt(bf.readLine());
        Integer n2 = Integer.parseInt(bf.readLine());
        Integer mn = (n2<n1)?n2:n1;
        Integer NOD=1;
        if (mn<=0)
            throw new Exception();
        for(int ii=1;ii<=mn;ii++){
            if (n1%ii==0&n2%ii==0)
                NOD = ii;
        }
        System.out.println(NOD);
    }

}
