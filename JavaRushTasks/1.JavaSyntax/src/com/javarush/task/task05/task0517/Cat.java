package com.javarush.task.task05.task0517;

/* 
Конструируем котиков
*/

public class Cat {
    //напишите тут ваш код
    private String name, color, address;
    private int age, weight;

    public Cat(String name) {
        this.name = name;
        this.age = 1;
        this.weight = 1;
        this.color = "black";
    }

    public Cat(String name, int weight, int age) {
        this.name = name;
        this.age = age;
        this.weight = weight;
        this.color = "black";
    }

    public Cat(String name, int age) {
        this.name = name;
        this.age = age;
        this.weight = 1;
        this.color = "black";
    }

    public Cat(int weight, String color, String address ) {
        this.color = color;
        this.address = address;
        this.weight = weight;
        this.age = 1;
    }

    public Cat(int weight, String color ) {
        this.color = color;
        this.weight = weight;
        this.age = 1;
    }
    public static void main(String[] args) {

    }
}
