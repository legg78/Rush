package com.javarush.games.racer.road;

import com.javarush.engine.cell.Game;
import com.javarush.games.racer.RacerGame;

import java.util.ArrayList;
import java.util.List;

public class RoadManager {
    public final static int LEFT_BORDER = RacerGame.ROADSIDE_WIDTH;
    public final static int RIGHT_BORDER = RacerGame.WIDTH - LEFT_BORDER;
    private final static int FIRST_LANE_POSITION = 16;
    private final static int FOURTH_LANE_POSITION = 44;
    private List<RoadObject> items = new ArrayList<>();

    private RoadObject createRoadObject(RoadObjectType type, int x, int y) {
        if (type.equals(RoadObjectType.THORN)) {
            return new Thorn(x, y);
        }
        else
            return null;
    }

    private void addRoadObject(RoadObjectType type, Game game) {
        int x = game.getRandomNumber(FIRST_LANE_POSITION, FOURTH_LANE_POSITION);
        int y = -1 * RoadObject.getHeight(type);
        RoadObject ro;
        ro = createRoadObject(type, x, y);
        if (ro != null) {
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
            ro.move(boost + ro.speed);
        }
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

    public void generateNewRoadObjects(Game game) {
        generateThorn(game);
    }
}
