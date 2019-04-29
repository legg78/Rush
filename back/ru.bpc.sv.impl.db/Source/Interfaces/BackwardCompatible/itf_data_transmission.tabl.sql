create table itf_data_transmission(
    id                      number(16)
  , entity_type             varchar2(8)
  , object_id               number(16)
  , eff_date                date
  , is_sent                 number(1)
  , is_received             number(1)
)
/
comment on table itf_data_transmission is 'Control output or input data transmission.'
/
comment on column itf_data_transmission.id is 'Primary key.'
/
comment on column itf_data_transmission.entity_type is 'Business-entity type.'
/
comment on column itf_data_transmission.object_id is 'Reference to the object.'
/
comment on column itf_data_transmission.eff_date is 'Event effective date.'
/
comment on column itf_data_transmission.is_sent is 'Data was sent'
/
comment on column itf_data_transmission.is_received is 'Data was received.'
/
