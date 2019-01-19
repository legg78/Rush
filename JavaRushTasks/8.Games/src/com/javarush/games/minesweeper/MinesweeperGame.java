package com.javarush.games.minesweeper;

import com.javarush.engine.cell.*;

import java.util.ArrayList;
import java.util.List;

public class MinesweeperGame extends Game {
    private static final int SIDE = 9;
    private GameObject[][] gameField = new GameObject[SIDE][SIDE];
    private int countMinesOnField;
    private static final String MINE = "\uD83D\uDCA3";
    private static final String FLAG = "\uD83D\uDEA9";
    private int countFlags;
    private boolean isGameStopped;
    private int countClosedTiles = SIDE*SIDE;
    private int score;


    @Override
    public void initialize() {
        setScreenSize(SIDE, SIDE);
        createGame();
        setScore(0);
    }

    private void createGame() {

        for (int ii=0;ii<SIDE;ii++)
            for (int nn=0;nn<SIDE;nn++) {
                boolean isMine =false;
                if (getRandomNumber(10)==9) {
                    isMine = true;

                }

                gameField[ii][nn] = new GameObject(nn, ii, isMine);
                setCellColor(ii, nn, Color.ORANGE);
                setCellValue(ii,nn,"");
            }

        countMineNeighbors();
        countFlags = countMinesOnField;

    }

    private List<GameObject> getNeighbors(GameObject go){

        int x = go.x;
        int y = go.y;
        List<GameObject> lg = new ArrayList<>();
        for (int i = y - 1; i < y + 2; i++) {        // координаты y
            for (int j = x - 1; j < x + 2; j++) {     // координаты x
                if (!(i < 0 || j < 0 || i > (SIDE - 1) || j > (SIDE - 1) || (i == y && j == x)))
                    lg.add(gameField[i][j]);
            }
        }
        return lg;
    }

    private  void countMineNeighbors() {
        int cm = 0;
        for (int ii=0;ii<SIDE;ii++)
            for (int nn=0;nn<SIDE;nn++) {
                if (!gameField[nn][ii].isMine)
                for (GameObject go : getNeighbors(gameField[nn][ii])) {
                    if (go.isMine)
                        gameField[nn][ii].countMineNeighbors++;
                }
            }
    }

    private void openTile(int x, int y) {
       if ( gameField[y][x].isOpen| gameField[y][x].isFlag| isGameStopped) {
           return;
       }
       gameField[y][x].isFlag = true;
       if (gameField[y][x].isMine) {
           //setCellValue(x, y, MINE);
           setCellValueEx(x, y, Color.RED, MINE);
           gameOver();
       }
       else {
           setCellNumber(x,y,gameField[y][x].countMineNeighbors);
           if (gameField[y][x].countMineNeighbors == 0) {
               setCellValue(x,y,"");
               for (GameObject go:getNeighbors(gameField[y][x])) {
                   if (!go.isFlag) {
                       openTile(go.x, go.y);

                   }
               }

           } else {
               setCellNumber(x, y, gameField[y][x].countMineNeighbors);
           }
           countMinesOnField++;
       }
       gameField[y][x].isOpen = true;
       countClosedTiles--;
       setCellColor(x,y,Color.GREEN);
       if (countMinesOnField==countClosedTiles&!gameField[y][x].isMine) {
           win();
       }
        if (gameField[y][x].isOpen&!gameField[y][x].isMine) {
            setScore(score+5);
        }


    }

    @Override
    public void onMouseLeftClick(int x, int y) {
        if (isGameStopped) {
            restart();
            return;
        }
        openTile(x, y);
    }
    @Override
    public void onMouseRightClick(int x, int y) {
        markTile(x,y);
    }
    private void markTile(int x, int y){
        GameObject gameObject = gameField[y][x];
        if(gameObject.isOpen|isGameStopped ) return;
      //  if(countFlags != 0 & !gameObject.isFlag) return;
        if (gameObject.isFlag){
            gameObject.isFlag = false;
            countFlags = countFlags+1 ;
            setCellValue(x, y, "");
            setCellColor(x, y, Color.ORANGE);
        }
        else {
            gameObject.isFlag = true;
            countFlags =  countFlags -1 ;
            setCellValue(x, y, FLAG);
            setCellColor(x, y, Color.YELLOW);
        }

    }

    private  void gameOver() {
        isGameStopped = true;
        showMessageDialog(Color.RED, "GAME OVER", Color.BLACK, 20);
    }

    private void win() {
        isGameStopped = true;
        showMessageDialog(Color.WHITE, "WIN!!!", Color.RED, 20);
    }

    @Override
    public void setScore(int score) {
        this.score = score;
    }

    private void restart(){
        isGameStopped = false;
        countClosedTiles = SIDE*SIDE;
        setScore(0);
        countMinesOnField = 0;
        createGame();
    }
}
