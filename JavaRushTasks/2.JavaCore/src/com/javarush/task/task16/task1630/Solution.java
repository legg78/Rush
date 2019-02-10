package com.javarush.task.task16.task1630;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class Solution {
    public static String firstFileName;
    public static String secondFileName;

    //add your code here - добавьте код тут
    public static volatile BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    static {
        try {
        firstFileName=reader.readLine();
        secondFileName=reader.readLine();}
        catch (IOException e) {}
    }
    public static void main(String[] args) throws InterruptedException {
        systemOutPrintln(firstFileName);
        systemOutPrintln(secondFileName);
    }

    public static void systemOutPrintln(String fileName) throws InterruptedException {
        ReadFileInterface f = new ReadFileThread();
        f.setFileName(fileName);
        f.start();
        //add your code here - добавьте код тут
        f.join();
        System.out.println(f.getFileContent());
    }

    public interface ReadFileInterface {

        void setFileName(String fullFileName);

        String getFileContent();

        void join() throws InterruptedException;

        void start();
    }

    //add your code here - добавьте код тут
    public static class ReadFileThread extends Thread implements ReadFileInterface {
        private String fileName;
        private ArrayList<String> lst=new ArrayList<>();
        @Override
        public void setFileName(String fullFileName) {
            fileName=fullFileName;
        }

        @Override
        public String getFileContent() {
            String st="";
            for(String str:lst)
                st+=str+" ";
            return st;
        }





        @Override
        public void run() {
            try {
                BufferedReader br = new BufferedReader(new FileReader(fileName));
                String st;
                while (true) {
                    st = br.readLine();
                    if (st == null) break;
                    lst.add(st);
                }
            } catch (Exception e) {}
        }
    }
}
