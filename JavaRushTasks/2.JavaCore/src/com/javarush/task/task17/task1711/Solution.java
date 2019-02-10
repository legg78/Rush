package com.javarush.task.task17.task1711;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/* 
CRUD 2
*/

public class Solution {
    public static volatile List<Person> allPeople = new ArrayList<Person>();

    static {
        allPeople.add(Person.createMale("Иванов Иван", new Date()));  //сегодня родился    id=0
        allPeople.add(Person.createMale("Петров Петр", new Date()));  //сегодня родился    id=1
    }

    public static void main(String[] args) {
        //start here - начни тут
        Person pr;
        SimpleDateFormat sm = new SimpleDateFormat("dd/MM/yyyy", Locale.ENGLISH);
        try {
            switch (args[0]) {
                case "-c": synchronized (allPeople){
                    for (int ii = 1; ii < args.length; ii += 3) {
                        if (args[ii + 1].equals("м"))

                            pr = Person.createMale(args[ii], sm.parse(args[ii + 2]));
                        else
                            pr = Person.createFemale(args[ii], sm.parse(args[ii + 2]));

                        allPeople.add(pr);
                        System.out.println(allPeople.size() - 1);
                    }
                    //  System.out.println(allPeople.get(2));
                    //System.out.println(allPeople.get);
                    // System.out.println(allPeople.get(2).getName()+" "+allPeople.get(2).getSex()+" "+allPeople.get(2).getBirthDate());
                }case("-u"): synchronized (allPeople){
                    for (int ii = 0; ii < args.length; ii += 4) {
                        allPeople.get(Integer.parseInt(args[ii + 1])).setName(args[ii + 2]);
                        allPeople.get(Integer.parseInt(args[ii + 1])).setSex(args[ii + 3].equals("м") ? Sex.MALE : Sex.FEMALE);
                        allPeople.get(Integer.parseInt(args[ii + 1])).setBirthDate(sm.parse(args[ii + 4]));
                    }
                }case("-d"): synchronized (allPeople) {
                    for (int ii = 1; ii < args.length; ii++) {
                        pr = allPeople.get(Integer.parseInt(args[ii]));
                        pr.setBirthDate(null);
                        pr.setName(null);
                        pr.setSex(null);
                    }
                }case("-i"): synchronized (allPeople){
                    for (int ii = 1; ii < args.length; ii++)
                        System.out.println(allPeople.get(Integer.parseInt(args[ii])));
                }

            }}

        catch (Exception e) {}
    }
}
