package com.javarush.task.task08.task0824;

/* 
Собираем семейство
*/

import java.util.ArrayList;

public class Solution {
    public static void main(String[] args) {
        //напишите тут ваш код
        Human ch1 = new Human();
        ch1.name = "ch1";
        ch1.sex = true;
        ch1.age=5;
        ch1.children = new ArrayList<Human>();

        Human ch2 = new Human();
        ch2.name = "ch2";
        ch2.sex = true;
        ch2.age=6;
        ch2.children = new ArrayList<Human>();

        Human ch3 = new Human();
        ch3.name = "ch3";
        ch3.sex = true;
        ch3.age=7;
        ch3.children = new ArrayList<Human>();

        Human dad = new Human();
        dad.name = "dad";
        dad.sex = true;
        dad.age=27;
        dad.children = new ArrayList<Human>();
        dad.children.add(ch1);
        dad.children.add(ch2);
        dad.children.add(ch3);

        Human mom = new Human();
        mom.name = "mom";
        mom.sex = false;
        mom.age=27;
        mom.children = new ArrayList<Human>();
        mom.children.add(ch1);
        mom.children.add(ch2);
        mom.children.add(ch3);

        Human gdad1 = new Human();
        gdad1.name = "gdad1";
        gdad1.sex = true;
        gdad1.age=100;
        gdad1.children = new ArrayList<Human>();
        gdad1.children.add(dad);

        Human gdad2 = new Human();
        gdad2.name = "gdad2";
        gdad2.sex = true;
        gdad2.age=100;
        gdad2.children = new ArrayList<Human>();
        gdad2.children.add(mom);

        Human gmom1 = new Human();
        gmom1.name = "gmom1";
        gmom1.sex = true;
        gmom1.age=100;
        gmom1.children = new ArrayList<Human>();
        gmom1.children.add(dad);

        Human gmom2 = new Human();
        gmom2.name = "gmom2";
        gmom2.sex = true;
        gmom2.age=100;
        gmom2.children = new ArrayList<Human>();
        gmom2.children.add(mom);

        System.out.println(gdad1);
        System.out.println(gmom1);
        System.out.println(gdad2);
        System.out.println(gmom2);
        System.out.println(dad);
        System.out.println(mom);
        System.out.println(ch1);
        System.out.println(ch2);
        System.out.println(ch3);
    }

    public static class Human {
        //напишите тут ваш код
        public int age;
        public String name;
        public boolean sex;
        public ArrayList<Human> children;




        public String toString() {
            String text = "";
            text += "Имя: " + this.name;
            text += ", пол: " + (this.sex ? "мужской" : "женский");
            text += ", возраст: " + this.age;

            int childCount = this.children.size();
            if (childCount > 0) {
                text += ", дети: " + this.children.get(0).name;

                for (int i = 1; i < childCount; i++) {
                    Human child = this.children.get(i);
                    text += ", " + child.name;
                }
            }
            return text;
        }
    }

}
