package com.javarush.task.task04.task0441;


/* 
Как-то средненько
*/
import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader reader = new InputStreamReader(stream);
        BufferedReader bfreader = new BufferedReader(reader);
        String snum = bfreader.readLine();
        int num1 = Integer.parseInt(snum);
        snum = bfreader.readLine();
        int num2 = Integer.parseInt(snum);
        snum = bfreader.readLine();
        int num3 = Integer.parseInt(snum);
        int num;
        if (num2<=num1&&num2<=num3) {
            num = num2;
            num2 = num1;
            num1 = num;
        }
        else  if (num3<=num1&&num3<=num2) {
            num = num3;
            num3 = num1;
            num1 = num;
        }



        if (num2>=num3)
            System.out.println( num3);
        else  {
            System.out.println(num2);
        }
    }
}
