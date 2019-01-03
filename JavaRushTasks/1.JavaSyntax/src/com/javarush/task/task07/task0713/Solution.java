package com.javarush.task.task07.task0713;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/* 
Играем в Jолушку
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //напишите тут ваш код
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        ArrayList<Integer> ar = new ArrayList<>();
        ArrayList<Integer> ar3 = new ArrayList<>();
        ArrayList<Integer> ar2 = new ArrayList<>();
        ArrayList<Integer> arr = new ArrayList<>();
        for (int ii = 0 ;ii++<20;) {
            ar.add(Integer.parseInt(reader.readLine()));
        }
        for (Integer ii:ar) {
            boolean fl = false;
            if (ii%3==0) {
                fl=true;
                ar3.add(ii);
            }
            if (ii%2==0) {
                fl=true;
                ar2.add(ii);
            }
            if (!fl) {

                arr.add(ii);
            }


        }

        printList(ar3);
        printList(ar2);
        printList(arr);
    }

    public static void printList(List<Integer> list) {
        //напишите тут ваш код
        for (Integer ii:list)
            System.out.println(ii);
    }
}
