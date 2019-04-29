create table opr_participant(
    oper_id             number(16)
  , part_key            as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , participant_type    varchar2(8)
  , inst_id             number(4)
  , network_id          number(4)
  , split_hash          number(4)
  , client_id_type      varchar2(8)
  , client_id_value     varchar2(200)
  , customer_id         number(12)
  , auth_code           varchar2(6)
  , card_id             number(12)
  , card_instance_id    number(12)
  , card_type_id        number(4)
  , card_mask           varchar2(24)
  , card_hash           number(12)
  , card_seq_number     number(3)
  , card_expir_date     date
  , card_service_code   varchar2(3)
  , card_country        varchar2(3)
  , card_network_id     number(4)
  , card_inst_id        number(4)
  , account_id          number(12)
  , account_type        varchar2(8)
  , account_number      varchar2(32)
  , account_amount      number(22,4)
  , account_currency    varchar2(3)
  , merchant_id         number(8)
  , terminal_id         number(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition opr_participant_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table opr_participant is 'Operation billing participants'
/

comment on column opr_participant.terminal_id is 'Terminal identifier'
/
comment on column opr_participant.oper_id is 'Reference to operation'
/
comment on column opr_participant.participant_type is 'Type of operation participant (Dictionary "PRTY" - Issuer, Acquirer, Destination)'
/
comment on column opr_participant.inst_id is 'Institution identifier'
/
comment on column opr_participant.network_id is 'Netrwork identifier'
/
comment on column opr_participant.split_hash is 'Hash value to split further processing'
/
comment on column opr_participant.client_id_type is 'Type of client identification'
/
comment on column opr_participant.client_id_value is 'Client identification value in according with client identifier type field'
/
comment on column opr_participant.customer_id is 'Customer identifier'
/
comment on column opr_participant.auth_code is 'Authorisation code'
/
comment on column opr_participant.card_id is 'Card identifier'
/
comment on column opr_participant.card_instance_id is 'Identifier of card instance'
/
comment on column opr_participant.card_type_id is 'Card type identifier'
/
comment on column opr_participant.card_mask is 'Card mask'
/
comment on column opr_participant.card_hash is 'Card hash'
/
comment on column opr_participant.card_seq_number is 'Card sequential number'
/
comment on column opr_participant.card_expir_date is 'Card expiration date'
/
comment on column opr_participant.card_service_code is 'Card service code'
/
comment on column opr_participant.card_country is 'Card country'
/
comment on column opr_participant.card_network_id is 'Card owner network'
/
comment on column opr_participant.card_inst_id is 'Card owner institution'
/
comment on column opr_participant.account_id is 'Account identifier involved in operation'
/
comment on column opr_participant.account_type is 'ISO account type involved in operation'
/
comment on column opr_participant.account_number is 'Account number'
/
comment on column opr_participant.account_amount is 'Account billing amount in account currency'
/
comment on column opr_participant.account_currency is 'Account currency'
/
comment on column opr_participant.merchant_id is 'Merchant identifier'
/
comment on column opr_participant.auth_code is 'Authorization code'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'OPR_PARTICIPANT' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table opr_participant add (part_key as (to_date(substr(lpad(to_char(oper_id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column opr_participant.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
