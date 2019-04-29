package ru.bpc.sv2.scheduler.process.mergeable;

public class DbalPostFileSaver extends DbalMergeableFileSaver {
    @Override
    public void save() throws Exception {
        super.save(false);
    }
}
