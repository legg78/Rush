package ru.bpc.sv2.scheduler.process.multithread.lob;


import java.sql.Connection;
import java.util.List;

public class Finisher implements Runnable{
    private long startTime;
    private List<Connection> connections;


    public Finisher(long startTime) {
        this.startTime = startTime;
    }

    @Override
    public void run() {


        //Todo delete broken file if we have an error.

        long result = System.currentTimeMillis() - startTime;
        System.out.println("Copying finished... : " + result);

    }
}
