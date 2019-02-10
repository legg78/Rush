package com.javarush.task.task14.task1419;

import java.io.FileNotFoundException;
import java.lang.annotation.AnnotationTypeMismatchException;
import java.util.ArrayList;
import java.util.FormatterClosedException;
import java.util.List;

/* 
Нашествие исключений
*/

public class Solution {
    public static List<Exception> exceptions = new ArrayList<Exception>();

    public static void main(String[] args) {
        initExceptions();

        for (Exception exception : exceptions) {
            System.out.println(exception);
        }
    }

    private static void initExceptions() {   //the first exception
        try {
            float i = 1 / 0;

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            int[] ii = new int[1];
            int nn=ii[1];

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            int[] ii = new int[-1];


        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
           "asda".substring(10);

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            Object[] o = "a;b;c".split(";");
            o[0] = 42;

        } catch (Exception e) {
            exceptions.add(e);
        }
        //напишите тут ваш код
        try {
            Integer n=null;
            float i = 1 / n;

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            throw new ClassCastException();

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            throw new FileNotFoundException();

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            throw new CloneNotSupportedException();

        } catch (Exception e) {
            exceptions.add(e);
        }
        try {
            throw new FormatterClosedException();

        } catch (Exception e) {
            exceptions.add(e);
        }
        System.out.println(exceptions.size());

    }
}
