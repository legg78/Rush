create table dpp_payment_plan (
    id number(16) not null
  , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , oper_id number(16)
  , account_id number(12)
  , card_id number(12)
  , product_id number(8)
  , oper_date date
  , oper_amount number(22 ,4)
  , oper_currency varchar2(3)
  , dpp_amount number(22 , 4)
  , interest_amount number(22 ,4)
  , status varchar2(8)
  , instalment_amount number(22 ,4)
  , instalment_total number(4)
  , instalment_billed number(4)
  , next_instalment_date date
  , debt_balance number(22 , 4)
  , inst_id number(4)
  , split_hash number(4)
 )

/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                        -- [@skip patch]
subpartition by list (split_hash)                                                          -- [@skip patch]
subpartition template                                                                      -- [@skip patch]
(                                                                                          -- [@skip patch]
    <subpartition_list>                                                                    -- [@skip patch]
)                                                                                          -- [@skip patch]
(                                                                                          -- [@skip patch]
    partition dpp_payment_plan_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                          -- [@skip patch]
******************** partition end ********************/
/

comment on table dpp_payment_plan is 'Deferred payment plan.'
/

comment on column dpp_payment_plan.id is 'Primary key. Equal to macros identifier.'
/
comment on column dpp_payment_plan.oper_id is 'Reference to operation'
/
comment on column dpp_payment_plan.account_id is 'Account identifier.'
/
comment on column dpp_payment_plan.card_id is 'Card identifier'
/
comment on column dpp_payment_plan.product_id is 'Product identifier.'
/
comment on column dpp_payment_plan.oper_date is 'Operation date creation.'
/
comment on column dpp_payment_plan.oper_amount is 'Total operation amount.'
/
comment on column dpp_payment_plan.oper_currency is 'Operation currency.'
/
comment on column dpp_payment_plan.dpp_amount is 'Amount used in payment plan'
/
comment on column dpp_payment_plan.interest_amount is 'Total interest amount.'
/
comment on column dpp_payment_plan.status is 'Operation status. (Active, Paid, Canceled)'
/
comment on column dpp_payment_plan.instalment_amount is 'Regular payment amount'
/
comment on column dpp_payment_plan.instalment_total is 'Total count of instalments'
/
comment on column dpp_payment_plan.instalment_billed is 'Count of billed instalments'
/
comment on column dpp_payment_plan.next_instalment_date is 'Next bill date'
/
comment on column dpp_payment_plan.debt_balance is 'Current debt balance'
/
comment on column dpp_payment_plan.inst_id is 'Institution identifier.'
/
comment on column dpp_payment_plan.split_hash is 'Value to split further processing.'
/
alter table dpp_payment_plan add (dpp_currency varchar2(3))
/
comment on column dpp_payment_plan.dpp_currency is 'Currency for the DPP amount'
/
alter table dpp_payment_plan add (reg_oper_id number(16))
/
comment on column dpp_payment_plan.reg_oper_id is 'DPP registration operation id'
/
alter table dpp_payment_plan add (posting_date date)
/
comment on column dpp_payment_plan.posting_date is 'DPP posting date'
/
alter table dpp_payment_plan add (oper_type varchar2(8))
/
comment on column dpp_payment_plan.oper_type is 'Original operation type'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'DPP_PAYMENT_PLAN' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table dpp_payment_plan add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column dpp_payment_plan.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
