create table app_flow(
    id                  number(4)
  , seqnum              number(4)
  , appl_type           varchar2(8)
  , template_appl_id    number(16)
  , inst_id             number(4)
  , is_customer_exist   number(1)
  , is_contract_exist   number(1)
  , customer_type       varchar2(8)
  , contract_type       varchar2(8)
  , mod_id              number(4)
  , xslt_source         clob
  , xsd_source          clob
)
/

comment on table app_flow is 'Application registration flow.'
/

comment on column app_flow.id is 'Primary key.'
/
comment on column app_flow.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_flow.appl_type is 'Application type.'
/
comment on column app_flow.template_appl_id is 'Reference to application template.'
/
comment on column app_flow.inst_id is 'Institution identifier.'
/
comment on column app_flow.is_customer_exist is 'Flow allowed only for existing customers.'
/
comment on column app_flow.is_contract_exist is 'Flow allowed only for existing contracts.'
/
comment on column app_flow.customer_type is 'Flow avalable only for cusomers of that type.'
/
comment on column app_flow.contract_type is 'Flow avalable only for contracts of that type.'
/
comment on column app_flow.mod_id is 'Modifier with contract and customer attributes define available flows for existing customer and/or contract.'
/
comment on column app_flow.xslt_source is 'Script to transform incoming data to final view.'
/
comment on column app_flow.xsd_source is 'Scheme to validate incoming application data.'
/