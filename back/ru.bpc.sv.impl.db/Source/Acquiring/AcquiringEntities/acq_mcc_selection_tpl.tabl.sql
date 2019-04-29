create table acq_mcc_selection_tpl (
    id        number(12) not null
    , seqnum  number(4)
)
/
comment on table acq_mcc_selection_tpl is 'Acquiring MCC selection template.'
/
comment on column acq_mcc_selection_tpl.id is 'Primary key'
/
comment on column acq_mcc_selection_tpl.seqnum is 'Data version sequencial number.'
/
