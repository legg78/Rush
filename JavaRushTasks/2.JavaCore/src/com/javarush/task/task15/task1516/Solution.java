package com.javarush.task.task15.task1516;

/* 
Значения по умолчанию
*/

import java.sql.SQLOutput;

public class Solution {
     int intVar;
     double doubleVar;
     Double DoubleVar;
     boolean booleanVar;
     Object ObjectVar;
     Exception ExceptionVar;
     String StringVar;
    public static void main(String[] args) {
        Solution sl = new Solution();
        System.out.println(sl.intVar);
        System.out.println(sl.doubleVar);
        System.out.println(sl.DoubleVar);
        System.out.println(sl.booleanVar);
        System.out.println(sl.ObjectVar);
        System.out.println(sl.ExceptionVar);
        System.out.println(sl.StringVar);
    }
}
