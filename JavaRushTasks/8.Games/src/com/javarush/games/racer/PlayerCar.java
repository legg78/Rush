package com.javarush.games.racer;

import com.javarush.games.racer.road.RoadManager;

public class PlayerCar extends  GameObject {
    private static int playerCarHeight = ShapeMatrix.PLAYER.length;
    public int speed = 1;
    private Direction direction;

    public Direction getDirection() {
        return direction;
    }

    public void setDirection(Direction direction) {
        this.direction = direction;
    }

    public void move() {

        if (this.x < RoadManager.LEFT_BORDER) {
            this.x = RoadManager.LEFT_BORDER;
            return;
        }

        if (this.x > (RoadManager.RIGHT_BORDER - width)) {
            this.x = RoadManager.RIGHT_BORDER - width;
            return;
        }

        if (direction.equals(Direction.LEFT))
            this.x--;

        if (direction.equals(Direction.RIGHT))
            this.x++;



    }
    public PlayerCar() {
        super (RacerGame.WIDTH / 2 + 2, RacerGame.HEIGHT - playerCarHeight - 1, ShapeMatrix.PLAYER);
    }

    public void stop () {
        this.matrix = ShapeMatrix.PLAYER_DEAD;
    }

    public void setSpeed(int speed) {
        this.speed = speed;
    }
}
