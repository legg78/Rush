package com.javarush.games.moonlander;

import com.javarush.engine.cell.*;

public class MoonLanderGame extends Game {
    public static final int WIDTH = 64;
    public static final int HEIGHT = 64;
    private GameObject landscape;
    private Rocket rocket;

    @Override
    public void initialize() {
        setScreenSize(MoonLanderGame.WIDTH, MoonLanderGame.HEIGHT);
        createGame();
        showGrid(false);
    }

    private void drawScene() {
        for (int xx=0; xx<64; xx++) {
            for (int yy=0; yy<64; yy++) {
                setCellColor(xx, yy, Color.BLACK);
            }
        }
        rocket.draw(this);
        landscape.draw(this);
    }

    private void createGame() {
        createGameObjects();
        drawScene();
    }

    private void createGameObjects() {
        rocket = new Rocket(MoonLanderGame.WIDTH/2, 0);
        landscape = new GameObject(0, 25, ShapeMatrix.LANDSCAPE);
    }
}
