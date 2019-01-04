package com.javarush.games.moonlander;

import com.javarush.engine.cell.*;

public class GameObject {
    public double x;
    public double y;
    public int [][] matrix;
    public int width;
    public int height;

    public GameObject(double x, double y, int[][] matrix) {
        this.x = x;
        this.y = y;
        this.width = matrix[0].length;
        this.height = matrix.length;
        this.matrix = matrix;
    }

    public void draw(Game game) {
        if (matrix==null)
            return;
        for (int yy=0; yy<matrix.length; yy++) {
            for (int xx=0; xx<matrix[yy].length; xx++) {
                game.setCellColor((int)x+xx, (int)y+yy, Color.values()[matrix[yy][xx]]);
            }
        }

    }
}
