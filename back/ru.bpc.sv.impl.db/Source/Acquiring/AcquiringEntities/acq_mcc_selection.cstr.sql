alter table acq_mcc_selection add constraint acq_mcc_selection_pk primary key(id)
/

alter table acq_mcc_selection add constraint acq_mcc_selection_uk
unique(terminal_id, oper_type, mcc)
/

alter table acq_mcc_selection drop constraint acq_mcc_selection_uk cascade
/
alter table acq_mcc_selection add constraint acq_mcc_selection_uk unique (
    oper_type
    , mcc
)
/
alter table acq_mcc_selection drop constraint acq_mcc_selection_uk cascade
/
alter table acq_mcc_selection add constraint acq_mcc_selection_uk unique (oper_type, mcc, purpose_id, oper_reason)
/
