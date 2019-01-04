package com.javarush.games.moonlander;

import com.javarush.engine.cell.*;

import java.util.List;

public class RocketFire extends GameObject {
    private List<int[][]> frames;
    private int frameIndex;
    private boolean isVisible;

    public RocketFire( List<int[][]> frameList) {
        super(0, 0, frameList.get(0));
        this.frames = frameList;
        this.frameIndex = 0;
        this.isVisible = false;
    }

    private void nextFrame() {

        if (++this.frameIndex>=this.frames.size())
            this.frameIndex = 0;
        this.matrix = this.frames.get(frameIndex);
    }

    @Override
    public void draw(Game game) {
        if (!this.isVisible) {
            return;
        }
        nextFrame();
        super.draw(game);
    }
}
