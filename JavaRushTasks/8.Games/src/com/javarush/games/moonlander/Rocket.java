package com.javarush.games.moonlander;

public class Rocket extends GameObject {
    private double speedY = 0;
    private double speedX = 0;
    private double boost = 0.05;
    private double slowdown = boost/10;

    public Rocket(double x, double y) {
        super(x, y, ShapeMatrix.ROCKET);
    }

    public void move(boolean isUpPressed, boolean isLeftPressed, boolean isRightPressed){
        if (isUpPressed)
            this.speedY-=this.boost;
        else
            this.speedY+=this.boost;
        this.y+=this.speedY;
        if (isLeftPressed) {
            this.speedX -= this.boost;
            this.x+=this.speedX;
        } else if (isRightPressed) {
            this.speedX += this.boost;
            this.x+=this.speedX;
        } else if (this.speedX>=-1*this.slowdown&&this.speedX<=this.slowdown) {
            this.speedX = 0;
        } else if (this.speedX<-1*this.slowdown) {
            this.speedX += this.slowdown;
            this.x+=this.speedX;
        } else if (this.speedX>this.slowdown) {
            this.speedX -= this.slowdown;
            this.x+=this.speedX;
        }

        checkBorders();

    }
    private void checkBorders() {
        if (this.x<0) {
            this.x = 0;
            this.speedX = 0;
        }
        if (this.x+this.width>MoonLanderGame.WIDTH ) {
            this.x = MoonLanderGame.WIDTH - this.width;
            this.speedX = 0;
        }
        if (this.y<0) {
            this.y = 0;
            this.speedY = 0;
        }

    }

    public boolean isStopped() {
        if (this.speedY<10*this.boost)
            return true;
        return false;
    }
}
