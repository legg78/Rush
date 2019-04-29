create table aup_chronopay(
    auth_id            number(16)
  , part_key           as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , tech_id            varchar2(36)
  , oper_date          date
  , network_id         number(4)
  , opcode             number(4)
  , amount             number(22,4)
  , account_id         number(12)
  , response_recieved  number(1)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_chronopay_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))      -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/
