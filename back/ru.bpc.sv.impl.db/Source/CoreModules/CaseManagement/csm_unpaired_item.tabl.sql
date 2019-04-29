create table csm_unpaired_item(
    id                      number(16)
  , is_unpaired_item        number(1)
)
/

comment on table csm_unpaired_item is 'Unpaired dispute operations.'
/
comment on column csm_unpaired_item.id is 'Primary key. Reference to OPR_OPERATION.ID'
/
comment on column csm_unpaired_item.is_unpaired_item is 'If dispute operation is unpaired item then 1 else null.'
/
