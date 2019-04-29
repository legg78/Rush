package ru.bpc.sv2.scheduler.process;

/**
 * Created by Gasanov on 18.03.2016.
 */
public class StatusConsumerImpl implements StatusConsumer {

    private long totalItems;
    private long processedItems;
    private long failedItems;
    private long rejectedItems;
    private int currentPhase;
    private int phaseCount;
    private boolean estimationChanged;

    @Override
    public void countEstimated(long totalItems) {
        this.totalItems = totalItems;
        estimationChanged = true;
    }

    @Override
    public void countUpdated(long processedItems, long failedItems, long rejectedItems) {
        this.processedItems = processedItems;
        this.failedItems = failedItems;
        this.rejectedItems = rejectedItems;
    }

    @Override
    public void phaseUpdated(int currentPhase, int phaseCount) {
        this.currentPhase = currentPhase;
        this.phaseCount = phaseCount;
    }

    public long getTotalItems() {
        return totalItems;
    }

    public long getProcessedItems() {
        return processedItems;
    }

    public long getFailedItems() {
        return failedItems;
    }

    public long getRejectedItems() {
        return rejectedItems;
    }

    public int getCurrentPhase() {
        return currentPhase;
    }

    public int getPhaseCount() {
        return phaseCount;
    }

    // -----------------------------------------------------------------------------------------------------------------

    public void setTotalItems(long totalItems){
        this.totalItems = totalItems;
    }

    public void setProcessedItems(long processedItems){
        this.processedItems = processedItems;
    }

    public void setFailedItems(long failedItems){
        this.failedItems = failedItems;
    }

    public void setRejectedItems(long rejectedItems){
        this.rejectedItems = rejectedItems;
    }

    public void setCurrentPhase(int currentPhase){
        this.currentPhase = currentPhase;
    }

    public void setPhaseCount(int phaseCount){
        this.phaseCount = phaseCount;
    }

    // -----------------------------------------------------------------------------------------------------------------

    public void increaseTotalItems(long count){
        this.totalItems += count;
    }

    public void increaseProcessedItems(long count){
        this.processedItems += count;
    }

    public void increaseFailedItems(long count){
        this.failedItems += count;
    }

    public void increaseRejectedItems(long count){
        this.rejectedItems += count;
    }

    // -----------------------------------------------------------------------------------------------------------------

    public boolean estimationChanged(){
        if(estimationChanged){
            estimationChanged = false;
            return true;
        }
        return false;
    }

    public void reset(){
        totalItems = 0;
        processedItems = 0;
        failedItems = 0;
        rejectedItems = 0;
        currentPhase = 0;
        phaseCount = 0;
    }
}
