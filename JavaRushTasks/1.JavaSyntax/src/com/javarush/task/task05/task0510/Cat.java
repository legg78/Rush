package com.javarush.task.task05.task0510;

/* 
Кошкоинициация
*/

public class Cat {
    //напишите тут ваш код
    public int age;
    public int weight;
    public int strength;
    public String color, address, name;
    /*
    - Имя,
            - Имя, вес, возраст
- Имя, возраст (вес стандартный)
- вес, цвет (имя, адрес и возраст неизвестны, это бездомный кот)
- вес, цвет, адрес (чужой домашний кот)*/
    public void initialize (String name) {
        this.name = name;
        this.age = 1;
        this.weight = 1;
        this.strength = 1;
        this.color =  "black";
    }

    public void initialize (String name, int weight, int age) {
        this.name = name;
        this.age = age;
        this.weight = weight;
        this.strength = 1;
        this.color =  "black";
    }

    public void initialize (String name,  int age) {
        this.name = name;
        this.age = age;
        this.weight = 1;
        this.strength = 1;
        this.color =  "black";
    }

    public void initialize ( int weight, String color) {

        this.age = 1;
        this.weight = weight;
        this.strength = 1;
        this.color =  color;
    }
    public void initialize ( int weight, String color, String address) {

        this.age = 1;
        this.weight = weight;
        this.strength = 1;
        this.color =  color;
        this.address = address;
    }

    public static void main(String[] args) {

    }
}
