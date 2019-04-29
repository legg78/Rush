create table rcn_srvp_data(
    id              number(16) not null
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , msg_id          number(16)
  , purpose_id      number(8)
  , param_id        number(8)
  , param_value     varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
  partition rcn_srvp_data_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/

comment on table rcn_srvp_data is 'Reconciliation message details'
/
comment on column rcn_srvp_data.id is 'Record identifier'
/
comment on column rcn_srvp_data.part_key is ''
/
comment on column rcn_srvp_data.msg_id is 'Reference to SRVP message'
/
comment on column rcn_srvp_data.purpose_id is 'ID of payment order purpose'
/
comment on column rcn_srvp_data.param_id is 'Reference to payment parameter from pmo_parameter'
/
comment on column rcn_srvp_data.param_value is 'Parameter value'
/
