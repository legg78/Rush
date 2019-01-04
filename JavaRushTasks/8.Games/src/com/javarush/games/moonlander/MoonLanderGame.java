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
    private GameObject platform;
    private boolean isGameStopped;
    private int score;

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
        this.isGameStopped = false;
        this.score = 1000;
        this.setTurnTimer(50);
        this.createGameObjects();
        this.drawScene();
    }

    private void createGameObjects() {
        this.rocket = new Rocket(MoonLanderGame.WIDTH/2, 0);
        this.landscape = new GameObject(0, 25, ShapeMatrix.LANDSCAPE);
        this.platform = new GameObject(23, MoonLanderGame.HEIGHT - 1, ShapeMatrix.PLATFORM);
    }

    @Override
    public void onTurn(int step) {
        this.rocket.move(this.isUpPressed,this.isLeftPressed,this.isRightPressed);
        if (score>0)
            score--;
        this.check();
        this.setScore(score);
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

        if (key==Key.SPACE && this.isGameStopped) {
            this.createGame();
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

    private void check() {
        if (this.rocket.isCollision(this.platform)&&this.rocket.isStopped())
            this.win();
        else if (this.rocket.isCollision(this.landscape))
            this.gameOver();

    }

    private void win() {
        this.rocket.land();
        this.isGameStopped = true;
        this.showMessageDialog(Color.WHITE, "WIN!!!", Color.RED, 12);
        this.stopTurnTimer();
    }

    private void gameOver() {
        this.rocket.crash();
        this.isGameStopped = true;
        this.showMessageDialog(Color.BLACK, "CRASH!!!", Color.RED, 12);
        this.stopTurnTimer();
        this.score = 0;
    }
}
