package com.javarush.task.task07.task0716;

import java.util.ArrayList;

/* 
Р или Л
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        ArrayList<String> list = new ArrayList<String>();
        list.add("роза"); // 0
        list.add("лоза"); // 1
        list.add("лира"); // 2
        list = fix(list);

        for (String s : list) {
            System.out.println(s);
        }
    }

    public static ArrayList<String> fix(ArrayList<String> list) {
        //напишите тут ваш код
        ArrayList<String> fList =  (ArrayList<String>) list.clone();

        for (int ii=0;ii<list.size();ii++) {

            if (list.get(ii).indexOf('р')>=0 && list.get(ii).indexOf('л')>=0)
            {}
            else if (list.get(ii).indexOf('р')>=0)
                fList.remove(list.get(ii));
            else if (list.get(ii).indexOf('л')>=0)
                fList.add(fList.indexOf(list.get(ii)),list.get(ii));

        }

        return fList;
    }
}