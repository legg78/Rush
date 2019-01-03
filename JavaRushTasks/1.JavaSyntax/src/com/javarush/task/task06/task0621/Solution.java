package com.javarush.task.task06.task0621;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.SQLOutput;

/* 
Родственные связи кошек
*/

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));



        String granddName = reader.readLine();
        Cat catGFather = new Cat(granddName);

        String grandmName = reader.readLine();
        Cat catGMother = new Cat(grandmName);

        String fatherName = reader.readLine();
        Cat catFather = new Cat(fatherName, null, catGFather);

        String motherName = reader.readLine();
        Cat catMother = new Cat(motherName, catGMother, null);

        String sonName = reader.readLine();
        Cat catSon = new Cat(sonName, catMother, catFather);

        String daughterName = reader.readLine();
        Cat catDaughter = new Cat(daughterName, catMother, catFather);



        System.out.println(catGFather);
        System.out.println(catGMother);
        System.out.println(catFather);
        System.out.println(catMother);
        System.out.println(catSon);
        System.out.println(catDaughter);
    }

    public static class Cat {
        private String name;
        private Cat parentM;
        private Cat parentD;

        Cat(String name) {
            this.name = name;
        }

        Cat(String name, Cat parentM, Cat parentD) {
            this.name = name;
            this.parentM = parentM;
            this.parentD = parentD;
        }

        @Override
        public String toString() {
            String str = "The cat's name is " + name + ", ";
            if (parentM == null)
                str+="no mother, ";
            else
                str+= "mother is " + parentM.name+", ";
            if (parentD == null)
                str+="no father";
            else
                str+= "father is " + parentD.name;
            return str;
        }
    }

}
