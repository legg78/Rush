package com.javarush.games.snake;

import com.javarush.engine.cell.*;

import java.util.ArrayList;
import java.util.List;

public class Snake {
    private Direction direction = Direction.LEFT;
    public  boolean isAlive = true;
    private List<GameObject> snakeParts = new ArrayList<>();
    private static final String HEAD_SIGN = "\uD83D\uDC7E";
    private static final String BODY_SIGN = "\u26AB";

    public Snake(int x, int y) {
        snakeParts.add(new GameObject(x,y));
        snakeParts.add(new GameObject(x + 1,y));
        snakeParts.add(new GameObject(x + 2,y));
    }

    public void draw(Game game) {
        Color sc;
        if (isAlive)
            sc = Color.BLACK;
        else
            sc = Color.RED;
        for (int ii=0;ii<snakeParts.size();ii++)
            if (ii==0)

                game.setCellValueEx(snakeParts.get(ii).x,snakeParts.get(ii).y, Color.NONE, HEAD_SIGN , sc, 75);
            else
                game.setCellValueEx(snakeParts.get(ii).x,snakeParts.get(ii).y, Color.NONE, BODY_SIGN, sc, 75);



    }

    public void setDirection(Direction direction) {
        if ((this.direction.equals(Direction.UP)&&direction.equals(Direction.DOWN)) ||
            (this.direction.equals(Direction.DOWN)&&direction.equals(Direction.UP)) ||
            (this.direction.equals(Direction.LEFT)&&direction.equals(Direction.RIGHT)) ||
            (this.direction.equals(Direction.RIGHT)&&direction.equals(Direction.LEFT)) ||

                (this.direction.equals(Direction.UP)&&snakeParts.get(0).y==snakeParts.get(1).y) ||
                (this.direction.equals(Direction.DOWN)&&snakeParts.get(0).y==snakeParts.get(1).y) ||
                (this.direction.equals(Direction.LEFT)&&snakeParts.get(0).x==snakeParts.get(1).x) ||
                (this.direction.equals(Direction.RIGHT)&&snakeParts.get(0).x==snakeParts.get(1).x)
        )
            return;
        this.direction = direction;
    }

    public void move (Apple apple) {
        GameObject go = createNewHead();
        if (go.x<0||go.x>=SnakeGame.WIDTH||go.y<0||go.y>=SnakeGame.HEIGHT||checkCollision(go)) {
            this.isAlive = false;
            return;
        }

            snakeParts.add(0,go);
        if ((go.x==apple.x) & (go.y == apple.y))
            apple.isAlive = false;
        else
            removeTail();
    }





    public boolean checkCollision(GameObject go) {
        for (GameObject gm :snakeParts) {
            if (gm.x == go.x && gm.y == go.y)
                return true;
        }
         return false;
    }

    public GameObject createNewHead () {
        System.out.println("!!!!!!!!!!!!!!!!!!!!"+snakeParts.size());
        int headX = snakeParts.get(0).x;
        int headY = snakeParts.get(0).y;
        if (direction.equals(Direction.UP))

            headY--;
        if (direction.equals(Direction.DOWN))

            headY++;
        if (direction.equals(Direction.LEFT))

            headX--;
        if (direction.equals(Direction.RIGHT))

            headX++;


        return new GameObject(headX, headY);
    }

    public void removeTail() {
        snakeParts.remove(snakeParts.size()-1);
    }

    public int getLength() {
        return snakeParts.size();
    }
}
