create table dsp_fin_message(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual    -- [@skip patch]
  , init_rule               number(4)
  , gen_rule                number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                                     -- [@skip patch]
(                                                                                                       -- [@skip patch]
    partition dsp_fin_message_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))                 -- [@skip patch]
)                                                                                                       -- [@skip patch]
******************** partition end ********************/
/

comment on table dsp_fin_message is 'Dispute financial message.'
/ 
comment on column dsp_fin_message.id is 'Financial message identifier (operation id).'
/
comment on column dsp_fin_message.init_rule is 'Initial rule.'
/
comment on column dsp_fin_message.gen_rule is 'Generate rule.'
/
