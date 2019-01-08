package com.javarush.task.task08.task0812;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/* 
Cамая длинная последовательность
*/
public class Solution {
    public static void main(String[] args) throws IOException {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<Integer> ar = new ArrayList<>();
        Integer mx = 0, cn =0;
        for (int ii = 0; ii<10;ii++)
            ar.add(Integer.parseInt(reader.readLine()));
        Integer pr = ar.get(0);

        for (Integer ii:ar) {
            if (pr.equals(ii))
                cn++;
            else {
                if (cn > mx) {
                   mx = cn;
                }
                pr = ii;
                cn = 1;
            }
        }
        if (cn>mx)
            mx = cn;
        System.out.println(mx);

    }
}