create table aci_token (
    id                          number(16)
    , name                      varchar2(2)
    , value                     varchar2(2000)
)
/
comment on table aci_token is 'BASE 24 tokens'
/
comment on column aci_token.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_token.name is 'Token identifier. Each token is assigned a unique token ID, ranging from 00 through ZZ. This allows for up to 1296 different token IDs.'
/
comment on column aci_token.value is 'The data token is the actual data. The data can be a single field, or a collection of fields.'
/
