package com.javarush.task.task08.task0816;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/* 
Добрая Зинаида и летние каникулы
*/

public class Solution {
    public static HashMap<String, Date> createMap() throws ParseException {
        DateFormat df = new SimpleDateFormat("MMMMM d yyyy", Locale.ENGLISH);
        HashMap<String, Date> map = new HashMap<String, Date>();
        map.put("Stallone", df.parse("JUNE 1 1980"));

        //напишите тут ваш код
        map.put("S1", df.parse("JULY 1 1980"));
        map.put("S2", df.parse("MARCH 1 1980"));
        map.put("S3", df.parse("APRIL 1 1980"));
        map.put("S4", df.parse("MAY 1 1980"));
        map.put("S5", df.parse("MAY 1 1980"));
        map.put("S6", df.parse("MAY 1 1980"));
        map.put("S7", df.parse("MAY 1 1980"));
        map.put("S8", df.parse("MAY 1 1980"));
        map.put("S9", df.parse("MAY 1 1980"));
        return map;
    }

    public static void removeAllSummerPeople(HashMap<String, Date> map) {
        //напишите тут ваш код

        map.entrySet().removeIf(e ->{
            DateFormat df = new SimpleDateFormat("MMMMM d yyyy", Locale.ENGLISH);
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(e.getValue().getTime());
            if (calendar.get(Calendar.MONTH) > 4 && calendar.get(Calendar.MONTH) < 8)
                return true;
            return false;
        }  );



    }

    public static void main (String[] args)   {

    }
}
