create table com_country (
    id                      number(4) not null
    , seqnum                number(4)
    , code                  varchar2(3)
    , name                  varchar2(3)
    , curr_code             varchar2(3)
    , visa_country_code     varchar2(3)
    , mastercard_region     varchar2(3)
    , mastercard_eurozone   varchar2(3)
)
/

comment on table com_country is 'This table contains the numeric and alphanumeric country codes'
/

comment on column com_country.id is 'Record identifier'
/

comment on column com_country.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_country.code is 'The numeric country code established by the International Organization for Standardization (ISO).'
/

comment on column com_country.name is 'The alphanumeric country code.'
/

comment on column com_country.curr_code is 'The numeric currency code associated with the country code established by ISO.'
/

comment on column com_country.visa_country_code is 'Country code established by VISA'
/

comment on column com_country.mastercard_region is 'Country region established by MASTERCARD'
/

comment on column com_country.mastercard_eurozone is 'Eurozone indicator established by MASTERCARD'
/

alter table com_country add visa_region number(1)
/
comment on column com_country.visa_region is 'Visa Europe region'
/
alter table com_country drop column visa_region
/
alter table com_country add visa_region varchar2(8 char)
/
comment on column com_country.visa_region is 'Visa region (US, CANADA, CEMEA, AP, EU, LAC)'
/
alter table com_country add sepa_indicator varchar2(1)
/
comment on column com_country.sepa_indicator is 'SEPA participant indicator (S - SEPA participant, T - Non-SEPA participant, N - Not applicable)'
/
