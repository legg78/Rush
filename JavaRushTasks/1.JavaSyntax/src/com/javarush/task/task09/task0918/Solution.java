package com.javarush.task.task09.task0918;

/* 
Все свои, даже исключения
*/

public class Solution {
    public static void main(String[] args) {
    }
    
    static class MyException extends Throwable{
    }

    static class MyException2 extends Throwable{
    }

    static class MyException3 extends RuntimeException{
    }

    static class MyException4 extends RuntimeException{
    }
}

