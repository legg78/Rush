create table com_dictionary
(
    id              number(8)                        
  , dict            varchar2(4)
  , code            varchar2(4)
  , is_numeric      number(1)                        default 0
  , is_editable     number(1)                        default 0
  , inst_id         number(4)
  , module_code     varchar2(3)
)
/

comment on table com_dictionary is 'System dictionary. Store all enumaration types values.'
/

comment on column com_dictionary.id is 'Primary key.'
/

comment on column com_dictionary.dict is 'Dictionary code.'
/

comment on column com_dictionary.code is 'Article code.'
/

comment on column com_dictionary.is_numeric is 'If true dictionary could have only numeric values.'
/

comment on column com_dictionary.is_editable is 'If true dictionary could be modified by user.'
/

comment on column com_dictionary.inst_id is 'Institution identifier.'
/

comment on column com_dictionary.module_code is 'Module code.'
/