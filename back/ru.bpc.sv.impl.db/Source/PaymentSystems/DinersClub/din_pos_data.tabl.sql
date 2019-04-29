create table din_pos_data(
    pos_article                 varchar2(8)
  , pos_value                   varchar2(1)
)
/

comment on table din_pos_data is 'Reference table for mapping SmartVista dictionary articles with PoS (point of service) values to Diners Club PoS values'
/
comment on column din_pos_data.pos_article is 'SmartVista PoS dictionary article'
/
comment on column din_pos_data.pos_value is 'Diners Club PoS value'
/
