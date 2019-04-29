create or replace type dsp_list_condition_tpr as object (
    id                          number(4)
  , func_order                  number(4)
  , init_rule                   number(8)
  , gen_rule                    number(8)
  , is_online                   number(1)
  , msg_type                    varchar2(8)
  , mod_id                      number(4)
  , condition                   number(1)
)
/
