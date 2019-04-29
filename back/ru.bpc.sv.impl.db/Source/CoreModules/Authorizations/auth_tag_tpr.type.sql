create or replace type auth_tag_tpr as object (
    oper_id      number(16)
  , tag_id       number(8)
  , tag_value    varchar2(2000)
  , tag_name     varchar2(4000)
)
/
