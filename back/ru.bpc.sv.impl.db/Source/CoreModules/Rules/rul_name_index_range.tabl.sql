create table rul_name_index_range (
    id                  number(8)
    , inst_id           number(4)
    , entity_type       varchar2(8)
    , algorithm         varchar2(8)
    , low_value         number(16)
    , high_value        number(16)
    , current_value     number(16)
)
/
comment on table rul_name_index_range is 'Definition of index range used for entity name generation'
/
comment on column rul_name_index_range.inst_id is 'Institution that owns index range'
/
comment on column rul_name_index_range.entity_type is 'Entity type to which range will be used'
/
comment on column rul_name_index_range.algorithm is 'Index value fetching algorithm'
/
comment on column rul_name_index_range.low_value is 'Low value of range'
/
comment on column rul_name_index_range.high_value is 'High value of range'
/
comment on column rul_name_index_range.current_value is 'Currenct value of range'
/
comment on column rul_name_index_range.id is 'Record identifier'
/
alter table rul_name_index_range modify low_value number(24)
/
alter table rul_name_index_range modify high_value number(24)
/
alter table rul_name_index_range modify current_value number(24)
/
