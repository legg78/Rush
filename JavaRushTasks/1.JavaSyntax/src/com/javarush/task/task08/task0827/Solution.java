package com.javarush.task.task08.task0827;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.temporal.ChronoUnit;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/* 
Работа с датой
*/

public class Solution {
    public static void main (String[] args) throws Exception {

        System.out.println(isDateOdd("MAY 1 2013"));
    }

    public static boolean isDateOdd  (String date) {
        DateFormat formatter =  new SimpleDateFormat("MMM d y", Locale.US);
        Date dt;
        try {
             dt = (Date) formatter.parse(date);
            Date bY = new Date();
            Calendar cBY = Calendar.getInstance();
            Calendar cTD = Calendar.getInstance();

            cTD.setTime(dt);
            cBY.setTime(dt);
            cBY.set(Calendar.DAY_OF_YEAR, 1);
            System.out.println((ChronoUnit.DAYS.between(cBY.toInstant(), cTD.toInstant())));
            System.out.println(cBY.toInstant());
            System.out.println(cTD.toInstant());
            if ( (ChronoUnit.DAYS.between(cBY.toInstant(), cTD.toInstant())+1)%2==1)

                return true;
            return false;
        } catch(Exception e) {
            System.out.println(1111);
        }
        return false;
    }
}
