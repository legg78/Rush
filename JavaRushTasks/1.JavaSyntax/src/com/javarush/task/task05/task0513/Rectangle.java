package com.javarush.task.task05.task0513;

/* 
Собираем прямоугольник
*/

public class Rectangle {
    //напишите тут ваш код
public int top, left, width, height;
public void initialize (int top, int left, int width, int height) {
    this.top = top;
    this.left = left;
    this.width = width;
    this.height = height;
}
    public void initialize (int top, int left, int width) {
        this.top = top;
        this.left = left;
        this.width = width;
        this.height = width;
    }
    public void initialize (int top, int left, Rectangle rectangle) {
        this.top = top;
        this.left = left;
        this.width = rectangle.width;
        this.height = rectangle.height;
    }
    public void initialize (int top,  Rectangle rectangle) {
        this.top = top;
        this.left = rectangle.left;
        this.width = rectangle.width;
        this.height = rectangle.height;
    }
    public static void main(String[] args) {

    }
}
