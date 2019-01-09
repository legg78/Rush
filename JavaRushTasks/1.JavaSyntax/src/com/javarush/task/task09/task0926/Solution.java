package com.javarush.task.task09.task0926;

import java.util.ArrayList;

/* 
Список из массивов чисел
*/

public class Solution {
    public static void main(String[] args) {
        ArrayList<int[]> list = createList();
        printList(list);
    }

    public static ArrayList<int[]> createList() {
        //напишите тут ваш код
        ArrayList<int[]> ar = new ArrayList<>();
        ar.add(new int[5]);
        ar.add(new int[2]);
        ar.add(new int[4]);
        ar.add(new int[7]);
        ar.add(new int[0]);
        for (int nn =0; nn<ar.size(); nn++)
            for (int ii=0; ii<ar.get(nn).length;ii++)
                 ar.get(nn)[ii]=ii;
        return ar;
    }

    public static void printList(ArrayList<int[]> list) {
        for (int[] array : list) {
            for (int x : array) {
                System.out.println(x);
            }
        }
    }
}
