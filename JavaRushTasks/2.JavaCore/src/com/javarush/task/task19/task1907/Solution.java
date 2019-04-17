package com.javarush.task.task19.task1907;

/* 
Считаем слово
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws IOException {
        InputStreamReader is = new InputStreamReader(System.in);
        BufferedReader bf = new BufferedReader(is);
        String f1 = bf.readLine();
        is.close();
        bf.close();
        String str = "";
        FileReader fr = new FileReader(f1);

        while (fr.ready()) {

            str += (char)fr.read();




        }
        //str = str.replace(".","");
        //str = str.replace("world",".");
        String data2 = str.replaceAll("\\bworld\\b","");


        System.out.println(  (str.length()-data2.length())/5);
        fr.close();


    }
}
