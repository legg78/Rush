package ru.bpc.sv2.scheduler.process.mergeable;

public class AccountsTurnoverPostFileSaver extends AccountsTurnoverFileSaver {
    @Override
    public void save() throws Exception {
        super.save(false);
    }
}
