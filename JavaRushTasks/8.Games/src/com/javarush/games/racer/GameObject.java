package com.javarush.games.racer;

import com.javarush.engine.cell.*;

public class GameObject {
    public int x;
    public int y;
    public int[][] matrix;
    public int width;
    public int height;

    public GameObject (int x, int y, int[][] matrix) {
        this.x = x;
        this.y = y;
        this.matrix = matrix;
        this.width = matrix[0].length;
        this.height = matrix.length;
    }

    public GameObject (int x, int y) {
        this.x = x;
        this.y = y;
    }

    public void draw(Game game) {
        for (int xx = 0; xx < matrix.length; xx++) {
            for (int yy = 0; yy < matrix[xx].length; yy++) {
                game.setCellColor(this.x + xx,this.y + yy, Color.values()[matrix[xx][yy]]);
            }
        }
    }


}
