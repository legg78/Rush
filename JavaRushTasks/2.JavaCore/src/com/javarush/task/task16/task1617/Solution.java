package com.javarush.task.task16.task1617;

/* 
Отсчет на гонках
*/

public class Solution {
    public static volatile int numSeconds = 3;

    public static void main(String[] args) throws InterruptedException {
        RacingClock clock = new RacingClock();
        //add your code here - добавь код тут
        try  {  Thread.sleep(3500);
            clock.interrupt();
        } catch (Exception e) {
        }
    }

    public static class RacingClock extends Thread {
        public RacingClock() {
            start();

        }

        public void run() {
            //add your code here - добавь код тут
            try  {
            for (int ii=numSeconds;ii>0;ii--) {
                System.out.println(numSeconds--);
                Thread.sleep(1000);
                }
                System.out.println("Марш!");
            } catch (Exception e) {
                System.out.println("Прервано!");
            }
        }
    }
}
