package com.javarush.games.racer.road;

import com.javarush.games.racer.RacerGame;

public class RoadManager {
    public final static int LEFT_BORDER = RacerGame.ROADSIDE_WIDTH;
    public final static int RIGHT_BORDER = RacerGame.WIDTH - LEFT_BORDER;
    private RoadObject createRoadObject(RoadObjectType type, int x, int y) {
        if (type.equals(RoadObjectType.THORN)) {
            return new Thorn(x, y);
        }
        else
            return null;
    }
}
