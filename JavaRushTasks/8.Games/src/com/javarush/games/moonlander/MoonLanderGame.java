package com.javarush.games.moonlander;

import com.javarush.engine.cell.*;

public class MoonLanderGame extends Game {
    public static final int WIDTH = 64;
    public static final int HEIGHT = 64;
    private GameObject landscape;
    private Rocket rocket;
    private boolean isUpPressed;
    private boolean isLeftPressed;
    private boolean isRightPressed;

    @Override
    public void initialize() {
        this.setScreenSize(MoonLanderGame.WIDTH, MoonLanderGame.HEIGHT);
        this.createGame();
        this.showGrid(false);
    }

    private void drawScene() {
        for (int xx=0; xx<64; xx++) {
            for (int yy=0; yy<64; yy++) {
                this.setCellColor(xx, yy, Color.BLACK);
            }
        }
        rocket.draw(this);
        landscape.draw(this);
    }

    private void createGame() {
        this.isLeftPressed = false;
        this.isRightPressed = false;
        this.isUpPressed = false;
        this.setTurnTimer(50);
        this.createGameObjects();
        this.drawScene();
    }

    private void createGameObjects() {
        this.rocket = new Rocket(MoonLanderGame.WIDTH/2, 0);
        this.landscape = new GameObject(0, 25, ShapeMatrix.LANDSCAPE);
    }

    @Override
    public void onTurn(int step) {
        this.rocket.move(this.isUpPressed,this.isLeftPressed,this.isRightPressed);
        this.drawScene();
    }

    @Override
    public void setCellColor(int x, int y, Color color) {
        if (x>=MoonLanderGame.WIDTH||y>=MoonLanderGame.HEIGHT||x<0||y<0)
            return;

        super.setCellColor(x, y, color);
    }

    @Override
    public void onKeyPress(Key key) {
        if (key==Key.UP) {
        this.isUpPressed = true;
        }
        if (key==Key.LEFT) {
            this.isLeftPressed = true;
            this.isRightPressed = false;
        }
        if (key==Key.RIGHT) {
            this.isLeftPressed = false;
            this.isRightPressed = true;
        }

}

    @Override
    public void onKeyReleased(Key key) {
        if (key==Key.UP) {
            this.isUpPressed = false;
        }
        if (key==Key.LEFT) {
            this.isLeftPressed = false;

        }
        if (key==Key.RIGHT) {
            this.isRightPressed = false;
        }

    }
}
