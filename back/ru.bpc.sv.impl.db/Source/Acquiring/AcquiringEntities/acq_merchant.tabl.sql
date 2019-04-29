create table acq_merchant (
    id              number(8)
  , seqnum          number(4)
  , merchant_number varchar2(15)
  , merchant_name   varchar2(200)
  , merchant_type   varchar2(8)
  , parent_id       number(8)
  , mcc             varchar2(4)
  , status          varchar2(8)
  , contract_id     number(12)
  , inst_id         number(4)
  , split_hash      number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table acq_merchant is 'Merchants. All levels of acquiring structure.'
/
comment on column acq_merchant.id is 'Primary key.'
/
comment on column acq_merchant.seqnum is 'Sequence number. Describe data version.'
/
comment on column acq_merchant.merchant_number is 'External merchant identifier. Unique inside institution.'
/
comment on column acq_merchant.merchant_name is 'Merchant name sending into payment network.'
/
comment on column acq_merchant.merchant_type is 'Merchant type (level) defining by bank.'
/
comment on column acq_merchant.parent_id is 'Reference to parent merchant level in accordance with acquiring hierarchy.'
/
comment on column acq_merchant.mcc is 'Merchant category code.'
/
comment on column acq_merchant.status is 'Merchant status (active, inactive).'
/
comment on column acq_merchant.contract_id is 'Reference to contract.'
/
comment on column acq_merchant.inst_id is 'Institution identifier.'
/
comment on column acq_merchant.split_hash is 'Hash value to split further processing'
/

alter table acq_merchant add partner_id_code varchar2(6)
/
comment on column acq_merchant.partner_id_code is 'Loyalty Program Partner ID'
/

comment on column acq_merchant.partner_id_code is 'MIR Loyalty Program Partner ID'
/
alter table acq_merchant add risk_indicator varchar2(8)
/
comment on column acq_merchant.partner_id_code is 'Fraud monitoring risk indicator'
/
comment on column acq_merchant.partner_id_code is 'Loyalty Program Partner ID'
/
comment on column acq_merchant.risk_indicator is 'Fraud monitoring risk indicator'
/
alter table acq_merchant add mc_assigned_id varchar2(6)
/
comment on column acq_merchant.mc_assigned_id is 'MasterCard Assigned ID'
/
comment on column acq_merchant.partner_id_code is 'MIR Loyalty Program Partner ID'
/
