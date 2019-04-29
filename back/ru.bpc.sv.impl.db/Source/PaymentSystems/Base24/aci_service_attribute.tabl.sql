create table aci_service_attribute (
    id               number(16)
    , part_key       as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , service_num    varchar2(4)
    , typ            varchar2(2)
    , db_cnt         varchar2(5)
    , db             varchar2(19)
    , cr_cnt         varchar2(5)
    , cr             varchar2(19)
    , adj_cnt        varchar2(5)
    , adj            varchar2(19)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aci_service_attr_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aci_service_attribute is 'Attribute of services supported by this terminal'
/

comment on column aci_service_attribute.typ is 'A code identifying each of the service types associated with the Services record.'
/
comment on column aci_service_attribute.db_cnt is 'The total number of debit transactions for the service during the current batch.'
/
comment on column aci_service_attribute.db is 'The total amount, in whole and fractional currency units (e.g., dollars and cents), for debit transactions for the service during the current batch.'
/
comment on column aci_service_attribute.cr_cnt is 'The total number of credit transactions for the service during the current batch.'
/
comment on column aci_service_attribute.cr is 'The total amount, in whole and fractional currency units (e.g., dollars and cents), for credit transactions for the service during the current batch.'
/
comment on column aci_service_attribute.adj_cnt is 'The total number of adjustment transactions for the service during the current batch.'
/
comment on column aci_service_attribute.adj is 'The total amount, in whole and fractional currency units (e.g., dollars and cents), for adjustment transactions for the service during the current batch.'
/
