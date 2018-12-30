package com.javarush.games.racer;

import com.javarush.engine.cell.*;
import com.javarush.games.racer.road.RoadManager;

public class RacerGame extends Game {
    public static final int WIDTH = 64;
    public static final int HEIGHT = 64;
    public static final int CENTER_X = WIDTH/2;
    public static final int ROADSIDE_WIDTH = 14;
    private RoadMarking roadMarking;
    private PlayerCar player;
    private RoadManager roadManager;
    private boolean isGameStopped;

    private void createGame() {
        roadMarking = new RoadMarking();
        player = new PlayerCar();
        roadManager = new RoadManager();
        drawScene();
        this.setTurnTimer(40);
        this.isGameStopped = false;

    }

    private void drawScene() {
        drawField();
        roadManager.draw(this);
        roadMarking.draw(this);
        player.draw(this);
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

    @Override
    public void onTurn(int step) {
        if (roadManager.checkCrush(player)) {
            gameOver();

        }
        else {
        moveAll();
        roadManager.generateNewRoadObjects(this);}
        drawScene();

    }
    private void moveAll() {
        roadMarking.move (player.speed);
        roadManager.move (player.speed);
        player.move();
    }

    @Override
    public void onKeyPress(Key key) {
        if (key.equals(Key.RIGHT))
            player.setDirection(Direction.RIGHT);
        if (key.equals(Key.LEFT))
            player.setDirection(Direction.LEFT);
        if (key.equals(Key.SPACE) && this.isGameStopped == true)
            createGame();
        if (key.equals(Key.UP))
            player.setSpeed(2);
        }

    @Override
    public void onKeyReleased(Key key) {
        if ((key == Key.RIGHT) && player.getDirection()==Direction.RIGHT) {
            player.setDirection(Direction.NONE);
        } else if (key==Key.LEFT && player.getDirection()==Direction.LEFT) {
            player.setDirection(Direction.NONE);
        } else if (key == Key.UP) {
            player.setSpeed ( 1 );
        }
    }

    private void gameOver(){
        this.isGameStopped = true;
        showMessageDialog(Color.RED, "GAME OVER" , Color.BLACK, 10);
        stopTurnTimer();
        player.stop();
    }


}
