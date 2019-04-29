create table din_type_of_charge(
    oper_type                    varchar2(8)
  , is_reversal                  number(1)
  , mcc                          varchar2(4)
  , terminal_type                varchar2(8)
  , type_of_charge               varchar2(2)
  , primary key (oper_type, is_reversal, mcc, terminal_type)
)
organization index
/

comment on table din_type_of_charge is 'Reference table for mapping SmartVista operation types to Diners Club field TYPCH (type of charge)'
/
comment on column din_type_of_charge.is_reversal is 'Reversal flag'
/
comment on column din_type_of_charge.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column din_type_of_charge.mcc is 'Merchant category code (ISO)'
/
comment on column din_type_of_charge.type_of_charge is 'Terminal type (TRMT dictionaty)'
/
comment on column din_type_of_charge.type_of_charge is 'Type of charge [TYPCH] that is associated with SmartVista operation type'
/

drop table din_type_of_charge
/

create table din_type_of_charge(
    oper_type                    varchar2(8)
  , is_reversal                  number(1)
  , terminal_type                varchar2(8)
  , mcc                          varchar2(4)
  , type_of_charge               varchar2(2)
  , is_incoming                  number(1)
)
/
comment on table din_type_of_charge is 'Reference table for mapping SmartVista operation types to Diners Club field TYPCH (type of charge)'
/
comment on column din_type_of_charge.is_reversal is 'Reversal flag'
/
comment on column din_type_of_charge.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column din_type_of_charge.mcc is 'Merchant category code (ISO)'
/
comment on column din_type_of_charge.type_of_charge is 'Terminal type (TRMT dictionaty)'
/
comment on column din_type_of_charge.type_of_charge is 'Type of charge [TYPCH] that is associated with SmartVista operation type'
/
comment on column din_type_of_charge.is_incoming is 'Incoming flag, it is true for records that are used for mapping Diners Club fields type_of_charge and mcc fields to SmartVista fields: oper_type, is_reversal, and terminal_type'
/

alter table din_type_of_charge add (is_icc_transaction number(1))
/
comment on column din_type_of_charge.is_icc_transaction is 'Chip card transaction flag'
/

comment on table din_type_of_charge is 'Obsolete, may be deleted'
/
