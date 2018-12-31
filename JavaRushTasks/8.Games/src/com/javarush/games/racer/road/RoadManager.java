package com.javarush.games.racer.road;

import com.javarush.engine.cell.Game;
import com.javarush.games.racer.GameObject;
import com.javarush.games.racer.PlayerCar;
import com.javarush.games.racer.RacerGame;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class RoadManager {
    public final static int LEFT_BORDER = RacerGame.ROADSIDE_WIDTH;
    public final static int RIGHT_BORDER = RacerGame.WIDTH - LEFT_BORDER;
    private final static int FIRST_LANE_POSITION = 16;
    private final static int FOURTH_LANE_POSITION = 44;
    private final static int PLAYER_CAR_DISTANCE = 12;
    private int passedCarsCount = 0;
    private List<RoadObject> items = new ArrayList<>();

    public int getPassedCarsCount() {
        return passedCarsCount;
    }

    private RoadObject createRoadObject(RoadObjectType type, int x, int y) {
        if (type.equals(RoadObjectType.THORN)) {
            return new Thorn(x, y);
        }
        else if (type == RoadObjectType.DRUNK_CAR) {
            return new MovingCar(x, y);
        }
        else {
            return new Car(type, x, y);
        }

    }

    private boolean isRoadSpaceFree(RoadObject object) {
        for (RoadObject ro : items) {
            if (ro.isCollisionWithDistance(object, PLAYER_CAR_DISTANCE))
                return false;
        }
        return true;
    }
    private void addRoadObject(RoadObjectType type, Game game) {
        int x = game.getRandomNumber(FIRST_LANE_POSITION, FOURTH_LANE_POSITION);
        int y = -1 * RoadObject.getHeight(type);
        RoadObject ro;
        ro = createRoadObject(type, x, y);
        if (ro != null && isRoadSpaceFree(ro)) {
            items.add(ro);
        }
    }

    public void draw(Game game) {
        for (RoadObject ro : items) {
            ro.draw(game);
        }
    }

    public void move(int boost) {
        for (RoadObject ro : items) {
            ro.move(boost + ro.speed, items);
        }

        deletePassedItems();
    }

    private boolean isThornExists() {
        for (RoadObject ro : items) {
            if (ro.type.equals(RoadObjectType.THORN)) {
                return true;
            }
        }
        return false;
    }

    private void generateThorn(Game game) {
        int num = game.getRandomNumber(100);
        if (num <10 && !isThornExists()) {
            addRoadObject(RoadObjectType.THORN, game);
        }
    }

    private void deletePassedItems() {
         List<RoadObject> itemc = new ArrayList<>(items);
          for (RoadObject ro : itemc) {
              if (ro.y >= RacerGame.HEIGHT) {
                  items.remove(ro);
                  if (ro.type != RoadObjectType.THORN) {
                      passedCarsCount++;
                  }
              }
          }
    }

    public void generateNewRoadObjects(Game game) {

        generateThorn(game);
        generateRegularCar(game);
        generateMovingCar(game);
    }

    public boolean checkCrush(PlayerCar playerCar) {
        for (RoadObject ro : items) {
            if (ro.isCollision(playerCar) )
                return true;

        }
        return false;
    }
    private void generateRegularCar(Game game) {
        int carTypeNumber = game.getRandomNumber(4);
        if (game.getRandomNumber(100) < 30 ) {
            addRoadObject(RoadObjectType.values()[carTypeNumber], game);
        }
    }

    private boolean isMovingCarExists() {
        for (RoadObject ro : items) {
            if (ro instanceof MovingCar)
                return true;

        }
        return false;
    }

    private void generateMovingCar(Game game) {
        if (game.getRandomNumber(100) < 10 && !isMovingCarExists()) {
            addRoadObject(RoadObjectType.DRUNK_CAR, game);
        }
    }
}
