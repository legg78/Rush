package com.javarush.task.task04.task0432;



/* 
Хорошего много не бывает
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        InputStream stream = System.in;
        InputStreamReader inputStreamReader = new InputStreamReader(stream);
        BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
        String str = bufferedReader.readLine();
        String sNum = bufferedReader.readLine();
        int num = Integer.valueOf(sNum);
        while (num-->0)
            System.out.println(str);
    }
}
