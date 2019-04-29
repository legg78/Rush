create table prs_method (
    id                      number(4)
    , inst_id               number(4)
    , seqnum                number(4)
    , pvv_store_method      varchar2(8)
    , pin_store_method      varchar2(8)
    , pin_verify_method     varchar2(8)
    , cvv_required          number(1)
    , icvv_required         number(1)
    , pvk_index             number(4)
    , key_schema_id         number(4)
    , service_code          varchar2(3)
    , dda_required          number(1)
    , imk_index             number(4)
    , private_key_component varchar2(8)
    , private_key_format    varchar2(8)
    , module_length         number(4)
    , max_script            number(4)
    , is_active             number(1)
    , decimalisation_table  varchar2(16)
    , exp_date_format       varchar2(8)
)
/
comment on table prs_method is 'Parameters that are describing method of card personalization'
/
comment on column prs_method.id is 'Record identifier'
/
comment on column prs_method.inst_id is 'Owner institution identifier'
/
comment on column prs_method.seqnum is 'Sequential number of record data version'
/
comment on column prs_method.pvv_store_method is 'Method of storing PVV (PVSM key)'
/
comment on column prs_method.pin_store_method is 'Method of storing PIN block (PNSM key)'
/
comment on column prs_method.pin_verify_method is 'Method of PIN verification (PNVM key)'
/
comment on column prs_method.cvv_required is 'Flag that CVV is required for card'
/
comment on column prs_method.icvv_required is 'Flag that ICVV is required for card'
/
comment on column prs_method.pvk_index is 'Current active index of PVK'
/
comment on column prs_method.key_schema_id is 'Schema of keys usage'
/
comment on column prs_method.service_code is 'Card service code'
/
comment on column prs_method.dda_required is 'Dynamic Data Authentication required'
/
comment on column prs_method.imk_index is 'Current active index of Issuer Master Keys'
/
comment on column prs_method.private_key_component is 'Integrated circuit card private key format component (PKCF key)'
/
comment on column prs_method.private_key_format is 'Integrated circuit card private key output format (PKOF key)'
/
comment on column prs_method.module_length is 'Integrated circuit card RSA key module length'
/
comment on column prs_method.max_script is 'Maximum number of concurrently transmitted scripts card'
/
comment on column prs_method.is_active is 'Active if method was used in personalization'
/
comment on column prs_method.decimalisation_table is '16 decimal digits that specify the mapping between hexadecimal & decimal numbers'
/
comment on column prs_method.exp_date_format is 'Card expiration date format for CVV2/CVC2'
/
alter table prs_method add pin_length number(4)
/
comment on column prs_method.pin_length is 'Pin length'
/
alter table prs_method add cvv2_required number(1)
/
comment on column prs_method.cvv2_required is 'Flag that CVV2 is required for card'
/
