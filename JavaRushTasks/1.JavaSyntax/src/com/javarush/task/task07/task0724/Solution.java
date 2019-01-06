package com.javarush.task.task07.task0724;

/* 
Семейная перепись
*/

public class Solution {
    public static void main(String[] args) {
        // напишите тут ваш код
        Human gdad1 = new Human("gdad1",true,100);
        Human gdad2 = new Human("gdad2",true,100);
        Human gmom1 = new Human("gdad1",false,100);
        Human gmom2 = new Human("gdad1",false,100);
        Human dad = new Human("dad",true,100, gdad1, gmom1);
        Human mom = new Human("mom",false,50, gdad2,gmom2);
        Human son = new Human("son",true,20, dad, mom);
        Human son1 = new Human("son1",true,20, dad, mom);
        Human son2 = new Human("son2",true,20, dad, mom);
        System.out.println(gdad1);
        System.out.println(gdad2);
        System.out.println(gmom1);
        System.out.println(gmom2);
        System.out.println(dad);
        System.out.println(mom);
        System.out.println(son);
        System.out.println(son1);
        System.out.println(son2);
    }

    public static class Human {
        // напишите тут ваш код
        private String name;
        private boolean sex;
        private int age;
        private Human father;
        private Human mother;

        public Human(String name, boolean sex, int age) {
            this.name = name;
            this.sex = sex;
            this.age = age;
        }

        public Human(String name, boolean sex, int age, Human father, Human mother) {
            this.name = name;
            this.sex = sex;
            this.age = age;
            this.father = father;
            this.mother = mother;
        }

        public String toString() {
            String text = "";
            text += "Имя: " + this.name;
            text += ", пол: " + (this.sex ? "мужской" : "женский");
            text += ", возраст: " + this.age;

            if (this.father != null)
                text += ", отец: " + this.father.name;

            if (this.mother != null)
                text += ", мать: " + this.mother.name;

            return text;
        }
    }
}