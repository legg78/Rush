package com.javarush.task.task15.task1525;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/* 
Файл в статическом блоке
*/

public class Solution {
    public static List<String> lines = new ArrayList<String>();
static {
try {
    BufferedReader bf = new BufferedReader(new InputStreamReader(new FileInputStream(new File(Statics.FILE_NAME))));
String str;
while (true) {
    str=bf.readLine();
    if (str == null)
        break;
    else
        lines.add(str);
}
}
catch (Exception e) {}
}
    public static void main(String[] args) {
        System.out.println(lines);
    }
}
