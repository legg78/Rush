package com.javarush.task.task15.task1527;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/* 
Парсер реквестов
*/

public class Solution {
    public static void main(String[] args) throws Exception {
        //add your code here
        ArrayList<String> pr = new ArrayList<>();
        ArrayList<String> obj = new ArrayList<>();
        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String url = bf.readLine();
        url = url.substring(url.indexOf('?')+1)+"&";
        while (true) {
            pr.add(url.substring(0, url.indexOf("&")));
            url = url.substring(url.indexOf("&") + 1);
            if (url.length()==0)
                break;
        }
        for (String st:pr) {
            int nn;
            nn=st.indexOf('=');
            if(nn==-1)
            System.out.print(st+" ");
           else {
                System.out.print(st.substring(0, nn) + " ");
                if (st.substring(0, nn).equals("obj"))
                    obj.add(st.substring(nn+1));
            }
        }
        System.out.println();
        for (String st:obj) {
            try {
                alert(Double.parseDouble(st));}
            catch( Exception e){alert(st);}
        }

    }

    public static void alert(double value) {
        System.out.println("double: " + value);
    }

    public static void alert(String value) {
        System.out.println("String: " + value);
    }
}
