create table lty_bonus (
    id           number(16)
  , part_key     as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , account_id   number(12)
  , card_id      number(12)
  , product_id   number(8)
  , service_id   number(8)
  , oper_date    date
  , posting_date date
  , start_date   date
  , expire_date  date
  , amount       number(22 , 4)
  , spent_amount number(22 , 4)
  , status       varchar2(8)
  , inst_id      number(4)
  , split_hash   number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition lty_bonus_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table lty_bonus is 'Loyalty bonus points.'
/
comment on column lty_bonus.id is 'Primary key. Macros identifier.'
/
comment on column lty_bonus.account_id is 'Bonus account identifier.'
/
comment on column lty_bonus.card_id is 'Card - loyalty program member'
/
comment on column lty_bonus.product_id is 'Product identifier'
/
comment on column lty_bonus.service_id is 'Loyalty service identifier'
/
comment on column lty_bonus.oper_date is 'Operation date.'
/
comment on column lty_bonus.posting_date is 'Macros posting date.'
/
comment on column lty_bonus.start_date is 'Bonus validity start date.'
/
comment on column lty_bonus.expire_date is 'Date to expire points.'
/
comment on column lty_bonus.amount is 'Bonus amount.'
/
comment on column lty_bonus.spent_amount is 'Spent bonus amount.'
/
comment on column lty_bonus.status is 'Bonus transaction status (Active, Spent, Expired).'
/
comment on column lty_bonus.inst_id is 'Institution identifier.'
/
comment on column lty_bonus.split_hash is 'Hash value to split further processing.'
/
alter table lty_bonus add (
    entity_type  varchar2(8)
  , object_id    number(16)
)
/
comment on column lty_bonus.entity_type is 'Entity type associated with bonus (card, account, merchant etc)'
/
comment on column lty_bonus.object_id is 'Identifier of associated object'
/
alter table lty_bonus add (fee_type varchar2(8))
/
comment on column lty_bonus.fee_type is 'Fee type (dictionary FETP)'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'LTY_BONUS' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table lty_bonus add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column lty_bonus.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
