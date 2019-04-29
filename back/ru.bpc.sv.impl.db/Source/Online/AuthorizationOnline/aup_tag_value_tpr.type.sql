create or replace type aup_tag_value_tpr as object(
    tag_id              number(8)
  , tag_value           varchar2(2000)
  , seq_number          number(4)
)
/
drop type aup_tag_value_tpr force
/
create or replace type aup_tag_value_tpr as object (
    tag_id           number(8)
  , tag_reference    varchar2(200)
  , tag_value        varchar2(200)
  , seq_number       number(4)
)
/
