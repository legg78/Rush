package ru.bpc.sv2.scheduler.process.mergeable;

public class AccountPostFileSaver extends PostFileSaver {
    @Override
    protected String getOriginalTrailer() {
        return "</clearing>";
    }
    @Override
    protected String getOriginalHeader() {
        return "<operation";
    }
    @Override
    protected String getConvertedTrailer() {
        return "</clearing>";
    }
    @Override
    protected String getConvertedHeader() {
        return "<operation";
    }
    @Override
    protected String convert(String raw) throws Exception {
        return raw;
    }
}
