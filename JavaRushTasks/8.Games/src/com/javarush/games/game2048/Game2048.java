package com.javarush.games.game2048;

import com.javarush.engine.cell.*;


public class Game2048 extends Game {
    private static final int SIDE = 4;
    private int[][] gameField = new int[4][4];
    private boolean isGameStopped = false;
    private int score = 0;

    @Override
    public void setScore(int score) {
        if (score==0)
            this.score=0;
        else
            this.score += score;
    }

    @Override
    public void initialize() {

        setScreenSize(SIDE, SIDE);
        createGame();
        drawScene();
    }

    private void createGame() {
        gameField = new int[4][4];
        setScore(0);
        createNewNumber();
        createNewNumber();

    }

    private void drawScene () {


        for (int ii=0;ii<SIDE;ii++)
            for (int nn=0;nn<SIDE;nn++)
                setCellColoredNumber(ii,nn,gameField[nn][ii]);
    }

    private void createNewNumber() {
        int x,y;
        while (true) {
            x = getRandomNumber(SIDE);
            y = getRandomNumber(SIDE);
            if (gameField[x][y]==0)
                break;
        }
        if (getRandomNumber(10)==9)

            gameField[x][y]=4;
        else
            gameField[x][y]=2;

        if (getMaxTileValue()>=2048)
            win();
    }

    private Color getColorByValue(int value) {
        if (value == 2)
            return Color.AQUA;
        if (value == 4)
            return Color.RED;
        if (value == 8)
            return Color.BURLYWOOD;
        if (value == 16)
            return Color.GREEN;
        if (value == 32)
            return Color.DIMGREY;
        if (value == 64)
            return Color.AZURE;
        if (value == 128)
            return Color.BLUE;
        if (value == 256)
            return Color.DARKSLATEBLUE;
        if (value == 512)
            return Color.BEIGE;
        if (value == 1024)
            return Color.ANTIQUEWHITE;
        if (value == 2048)
            return Color.CORAL;
        else
            return Color.WHITE;

    }
    private  void setCellColoredNumber(int x, int y, int value) {

        setCellValueEx(x,y,getColorByValue(value),value==0?"":String.valueOf(value));
    }

    private  boolean compressRow(int[] row) {
        boolean fl =false;
        for (int ii  = 1 ;ii<row.length;ii++) {
            for (int nn  = ii ;nn>0;nn--)
            if (row[nn-1]==0&&row[nn]!=0) {
                row[nn-1]=row[nn];
                row[nn]=0;
                fl=true;
            }

        }
        return fl;
    }
    private boolean mergeRow(int[] row) {
        boolean fl =false;
        for (int ii  = 1 ;ii<row.length;ii++) {

                if (row[ii-1]==row[ii]&&row[ii]!=0) {
                    row[ii-1]=row[ii]*2;
                    row[ii]=0;
                    setScore(row[ii-1]);
                    fl=true;

                }

        }
        return  fl;


    }

    @Override
    public void onKeyPress(Key key) {
        if (isGameStopped)
            if (key.equals(Key.SPACE)) {
                isGameStopped = false;
                createGame();
                drawScene();
            }
        else
            return;

        
        if (!canUserMove()) {
            gameOver();
            return;
        }


        if (key.equals(Key.LEFT)) {
            moveLeft();
            drawScene();
        }
        if (key.equals(Key.RIGHT)) {
            moveRight();
            drawScene();
        }
        if (key.equals(Key.UP)) {
            moveUp();
            drawScene();
        }
        if (key.equals(Key.DOWN)) {
            moveDown();
            drawScene();
        }

    }

    private void moveLeft() {

        boolean nreq=false;
        for (int[] ar:gameField) {

            nreq = nreq |compressRow(ar);
            if ( nreq | mergeRow(ar))
                nreq = true;
            if (nreq | compressRow(ar))
                nreq = true;

        }
        if (nreq) {
            createNewNumber();
        }


    }
    private void moveRight() {
        rotateClockwise();
        rotateClockwise();
        moveLeft();
        rotateClockwise();
        rotateClockwise();

    }
    private void moveUp() {
        rotateClockwise();
        rotateClockwise();
        rotateClockwise();
        moveLeft();
        rotateClockwise();

    }
    private void moveDown() {

        rotateClockwise();
        moveLeft();
        rotateClockwise();
        rotateClockwise();
        rotateClockwise();

    }
    private void rotateClockwise() {
        int[][] gf = new int[SIDE][SIDE];
        for (int ii = 0;ii<SIDE;ii++)
            for (int nn = 0;nn<SIDE;nn++)
                gf[nn][SIDE-1-ii] = gameField[ii][nn];
        gameField = gf;
    }
    private int getMaxTileValue() {
        int mx = 0;
        for (int ii = 0;ii<SIDE;ii++)
            for (int nn = 0;nn<SIDE;nn++)
                if (mx<gameField[ii][nn])
                    mx = gameField[ii][nn];
        return mx;
    }

    private void win() {
        isGameStopped = true;
        showMessageDialog(Color.WHITE, "WIN!!!", Color.RED, 20);
    }

    private void gameOver() {
        isGameStopped = true;
        showMessageDialog(Color.BLACK, "GAME OVER", Color.RED, 20);
    }
    private boolean canUserMove() {
        for (int ii = 0;ii<SIDE;ii++)
            for (int nn = 0;nn<SIDE;nn++) {

                if ((gameField[ii][nn] == 0)||(ii+1<SIDE&&gameField[ii][nn]==gameField[ii+1][nn])||(ii-1>=0&&gameField[ii][nn]==gameField[ii-1][nn])
                        ||(nn+1<SIDE&&gameField[ii][nn]==gameField[ii][nn+1])||(nn-1>=0&&gameField[ii][nn]==gameField[ii][nn-1]))
                    return true;
            }
        return false;
    }
}
