package com.javarush.task.task05.task0509;

/* 
Создать класс Friend
*/

public class Friend {
    //напишите тут ваш код
    private String name;
    private int age;
    private char sex;
    public void initialize (String name) {
        this.name = name;
    }
    public void initialize (String name, int age) {
        this.age = age;
        initialize(name);
    }
    public void initialize (String name, int age, char sex) {
        this.sex = sex;
        initialize(name, age);
    }
    public static void main(String[] args) {

    }
}
