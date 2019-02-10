package com.javarush.task.task17.task1710;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/* 
CRUD
*/

public class Solution {
    public static List<Person> allPeople = new ArrayList<Person>();

    static {
        allPeople.add(Person.createMale("Иванов Иван", new Date()));  //сегодня родился    id=0
        allPeople.add(Person.createMale("Петров Петр", new Date()));  //сегодня родился    id=1
    }

    public static void main(String[] args) {
        //start here - начни тут
        Person pr;
        SimpleDateFormat sm = new SimpleDateFormat("dd/MM/yyyy");
        try {
            if (args[0].equals("-c")) {
                if (args[2].equals("м"))

                    pr = Person.createMale(args[1], sm.parse(args[3]));
                else
                    pr = Person.createFemale(args[1], sm.parse(args[3]));

                allPeople.add(pr);
                System.out.println(allPeople.size() - 1);
              //  System.out.println(allPeople.get(2));
                //System.out.println(allPeople.get);
               // System.out.println(allPeople.get(2).getName()+" "+allPeople.get(2).getSex()+" "+allPeople.get(2).getBirthDate());
            } else if (args[0].equals("-u")) {
                 allPeople.get(Integer.parseInt(args[1])).setName(args[2]);
                allPeople.get(Integer.parseInt(args[1])).setSex(args[3].equals("м")?Sex.MALE:Sex.FEMALE);
                allPeople.get(Integer.parseInt(args[1])).setBirthDate(sm.parse(args[4]));
            } else if (args[0].equals("-d")) {
                pr=allPeople.get(Integer.parseInt(args[1]));
                pr.setBirthDate(null);
                pr.setName(null);
                pr.setSex(null);
            }
            else if (args[0].equals("-i")) {
                System.out.println(allPeople.get(Integer.parseInt(args[1])));
            }

        }

        catch (Exception e) {}
    }
}
