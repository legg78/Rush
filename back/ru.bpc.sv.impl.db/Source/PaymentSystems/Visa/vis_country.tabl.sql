create table vis_country
(
    visa_country_code   varchar2(2)
  , curr_code           varchar2(3)
  , session_file_id     number(8)
  , is_valid            number(1)
)
/

comment on table vis_country is 'VISA country dictionary.'
/

comment on column vis_country.visa_country_code is 'VISA country code.'
/

comment on column vis_country.curr_code is 'Default country currency code.'
/

comment on column vis_country.session_file_id is 'Incoming file identifier.'
/

comment on column vis_country.is_valid is 'Contains True by default. The value of False allows customers to lock certain BINs.'
/

alter table vis_country modify(session_file_id number(16))
/
