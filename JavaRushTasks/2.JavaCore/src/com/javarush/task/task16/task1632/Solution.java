package com.javarush.task.task16.task1632;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class Solution {
    public static List<Thread> threads = new ArrayList<>(5);
static {
    threads.add(new Thread(()->{while(true){}}));
    threads.add(new Thread(()->
    { try {
        while(true){Thread.sleep(0);}
    } catch (InterruptedException e) {
        System.out.println("InterruptedException");
    }}));
    threads.add(new Thread(()->
    { try {
        while(true){
          System.out.println("Ура");
            Thread.sleep(500);}
        } catch (Exception e) {

        }
    }
    )
    );

     class Th2 extends Thread implements Message{
         @Override
         public void showWarning() {
             this.interrupt();
         }

         @Override
         public void run() {
             while (!this.isInterrupted()){
             }
         }
     }
     threads.add(new Th2());
     threads.add(new Thread(()->{
             BufferedReader buff = new BufferedReader(new InputStreamReader(System.in));
    int result = 0;
    try{
        while (true) {
            try{
                int i = Integer.parseInt(buff.readLine());
                result += i;
            }catch (NumberFormatException nfe){
                System.out.println(result);
                break;
            }

        }
    }catch (IOException io){}}
             ));
}
    public static void main(String[] args) {

    }
}