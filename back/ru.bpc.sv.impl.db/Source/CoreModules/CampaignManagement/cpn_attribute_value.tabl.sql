create table cpn_attribute_value (
    id                  number(12)
  , campaign_id         number(8)  
  , attribute_value_id  number(12)
)
/
comment on table cpn_attribute_value is 'Campaign attributes value'
/
comment on column cpn_attribute_value.id is 'Value identifier'
/
comment on column cpn_attribute_value.campaign_id is 'Campaign identifier'
/
comment on column cpn_attribute_value.attribute_value_id is 'Campaign attribute identifier'
/
