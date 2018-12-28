package com.javarush.games.racer;

import com.javarush.engine.cell.*;

public class RacerGame extends Game {
    public static final int WIDTH = 64;
    public static final int HEIGHT = 64;
    public static final int CENTER_X = WIDTH/2;
    public static final int ROADSIDE_WIDTH = 14;

    private void createGame() {
        drawScene();
    }

    private void drawScene() {
        drawField();
    }

    private void drawField() {
        for (int xx = 0; xx < 64; xx++) {
            for (int yy = 0; yy < 64; yy++) {
                if (xx == CENTER_X)
                    setCellColor(xx, yy, Color.WHITE);
                else if (xx >= ROADSIDE_WIDTH && xx < (WIDTH - ROADSIDE_WIDTH) )
                    setCellColor(xx, yy, Color.DIMGREY);
                else
                    setCellColor(xx, yy, Color.GREEN);
            }

        }
    }

    @Override
    public void setCellColor(int x, int y, Color color) {
        if (x < 0 || x > 64 || y < 0 || y > 64)
            return;
        try {super.setCellColor(x, y, color);}
        catch (Exception e) {}

    }

    @Override
    public void initialize() {
        showGrid(false);
        setScreenSize(WIDTH, HEIGHT);
        createGame();
    }

}
