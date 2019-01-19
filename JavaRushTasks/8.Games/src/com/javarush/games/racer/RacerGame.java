package com.javarush.games.racer;

import com.javarush.engine.cell.*;
import com.javarush.games.racer.road.RoadManager;
import javafx.scene.text.TextFlow;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class RacerGame extends Game {
    public static final int WIDTH = 64;
    public static final int HEIGHT = 64;
    public static final int CENTER_X = WIDTH/2;
    public static final int ROADSIDE_WIDTH = 14;
    private static final int RACE_GOAL_CARS_COUNT = 40;
    private RoadMarking roadMarking;
    private PlayerCar player;
    private RoadManager roadManager;
    private boolean isGameStopped = true;
    private boolean isSet = false;
    private FinishLine finishLine;
    private ProgressBar progressBar;
    private int score;

    public boolean isDrunk() {
        return isDrunk;
    }

    private boolean isDrunk;
    private boolean isAbstinent;
    private Field iMS;//boolean
    private Field dC;//textflow
    private TextFlow tf;
    private Method sV;

    private void settings () {
        {
            if(!isSet) {
            showMessageDialog(Color.WHITE, "Нажмите стрелку влево для режима без пьяного водителя, вправо для режима с пьяным водителем",
                    Color.BLACK, 10);
            stopTurnTimer();
                }
            //abstinent = false;
        }
    }

    private void hideMessage() {
        try {

            iMS = Game.class.getDeclaredField("isMessageShown");
            iMS.setAccessible(true);
            dC = Game.class.getDeclaredField("dialogContainer");
            dC.setAccessible(true);
            tf = (TextFlow) dC.get(this);
            tf.setVisible(false);
            sV =  dC.getClass().getDeclaredMethod("setVisible");
            sV.invoke(dC,true);
        } catch (Exception e) {
        }
    }
    private void createGame() {
      //  isSetMode = true;

        roadMarking = new RoadMarking();
        player = new PlayerCar();
        roadManager = new RoadManager();
        finishLine = new FinishLine();
        progressBar = new ProgressBar(RACE_GOAL_CARS_COUNT);
        drawScene();

        this.setTurnTimer(40);
        this.isGameStopped = false;
        this.score = 3500;

    }

    private void drawScene() {
        drawField();

        roadMarking.draw(this);
        finishLine.draw(this);
        roadManager.draw(this);

        progressBar.draw(this);
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
        this.score-=5;
        if (!this.isSet) {
            settings();
            System.out.println("!!!!!!!!!!!!");
            return;
        }
        System.out.println("!!!!!!!!!!!!");
        if (!isSet)
        settings();
        if (roadManager.getPassedCarsCount() >= RACE_GOAL_CARS_COUNT) {
            finishLine.show();
        }
        if (roadManager.checkCrush(player)) {
            gameOver();

        }
        else {
        if (finishLine.isCrossed(player)) {
            win();

        } else {
        moveAll();
        roadManager.generateNewRoadObjects(this);}}
        setScore(this.score);
        drawScene();

    }
    private void moveAll() {
        roadMarking.move (player.speed);
        roadManager.move (player.speed);
        finishLine.move(player.speed);
        progressBar.move(roadManager.getPassedCarsCount());
        player.move();
    }

    @Override
    public void onKeyPress(Key key) {

        System.out.println(key);

        if (!isSet /*&& this.isGameStopped == true*/) {
            //void

            if (key.equals(Key.RIGHT)) {
                isDrunk = true;
                isSet=true;

                this.setTurnTimer(40);
                createGame();

                hideMessage();
            }
            else if (key.equals(Key.LEFT)) {

                isDrunk = false;
                isSet = true;
                System.out.println("setTurnTimer");
                this.setTurnTimer(40);
                createGame();
                hideMessage();

            }

                return;
        }
        if (key.equals(Key.RIGHT))
            player.setDirection(Direction.RIGHT);
        if (key.equals(Key.LEFT))
            player.setDirection(Direction.LEFT);
        if (key.equals(Key.SPACE) && this.isGameStopped == true) {
            //settings();
            System.out.println(11111);
            createGame();
        }

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

        isSet = false;
        settings();
        //isSet = false;

    }

    private void win(){
        isGameStopped = true;
        showMessageDialog(Color.WHITE, "WIN!!!", Color.RED, 30);
        stopTurnTimer();
        isSet = false;
        settings();
    }

}
