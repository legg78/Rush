package com.javarush.task.task05.task0526;

/* 
Мужчина и женщина
*/

public class Solution {
    public static void main(String[] args) {
        //напишите тут ваш код
        Man man1 = new Man("1",2,"3");
        Man man2 = new Man("4",5,"6");
        Woman woman1 = new Woman("7",8,"9");
        Woman woman2 = new Woman("10",11,"12");
        System.out.println(man1.name+" "+man1.age+" "+man1.address);
        System.out.println(man2.name+" "+man2.age+" "+man2.address);
        System.out.println(woman1.name+" "+woman1.age+" "+woman1.address);
        System.out.println(woman2.name+" "+woman2.age+" "+woman2.address);

    }

    //напишите тут ваш код
    public static class Man {
        private String name, address;
        private int age;

        public Man(String name, int age, String address) {
            this.name = name;
            this.address = address;
            this.age = age;
        }
    }

    public static class Woman {
        private String name, address;
        private int age;

        public Woman(String name, int age, String address) {
            this.name = name;
            this.address = address;
            this.age = age;
        }
    }
}
