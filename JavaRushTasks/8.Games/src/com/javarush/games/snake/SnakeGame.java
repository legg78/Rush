package com.javarush.games.snake;

import com.javarush.engine.cell.*;

public class SnakeGame  extends Game {
    public static final int WIDTH = 15;
    public static final int HEIGHT = 15;
    private boolean isGameStopped;
    private Snake snake;
    private int turnDelay;
    private Apple apple;
    private static  final int GOAL=28;
    private int score;

    private  void createNewApple() {
        while (true) {
            apple = new Apple(getRandomNumber(WIDTH), getRandomNumber(HEIGHT));
            if (!snake.checkCollision(apple))
                break;
        }
    }

    @Override
    public void initialize() {
        setScreenSize(WIDTH, HEIGHT);
        createGame();
    }

    private void createGame() {
        snake = new Snake(WIDTH / 2, HEIGHT / 2);
        turnDelay = 300;
        score = 0;
        setScore(score);
        setTurnTimer(turnDelay);
        isGameStopped = false;
        createNewApple();
        drawScene();

    }

    private void drawScene() {
        for (int ii=0;ii<WIDTH;ii++)
            for (int nn=0;nn<HEIGHT;nn++) {
                setCellValueEx(ii,nn,Color.DARKSEAGREEN,"");
            }
        snake.draw(this);
        apple.draw(this);
    }

    @Override
    public void onTurn(int step) {
        snake.move(apple);
        if ( apple.isAlive == false) {
            score+=5;
            setScore(score);
            createNewApple();
            turnDelay-=10;
            setTurnTimer(turnDelay);
        }
        if (!snake.isAlive)
            gameOver();
        if (snake.getLength()>GOAL)
            win();
        drawScene();
    }

    @Override
    public void onKeyPress(Key key) {
        if (key.equals(Key.UP))
            snake.setDirection(Direction.UP);
        if (key.equals(Key.DOWN))
            snake.setDirection(Direction.DOWN);
        if (key.equals(Key.LEFT))
            snake.setDirection(Direction.LEFT);
        if (key.equals(Key.RIGHT))
            snake.setDirection(Direction.RIGHT);
        if (key.equals(Key.SPACE)&&isGameStopped)
            createGame();
    }

    private void gameOver() {
        stopTurnTimer();
        this.isGameStopped = true;
        showMessageDialog(Color.BLACK, "GAME OVER", Color.RED, 20);

    }

    private void win() {
        stopTurnTimer();
        this.isGameStopped = true;
        showMessageDialog(Color.WHITE, "YOU WIN", Color.RED, 20);

    }



}
