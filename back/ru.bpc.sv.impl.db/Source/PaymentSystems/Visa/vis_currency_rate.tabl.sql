create table vis_currency_rate
(
  id                    number(16) not null,
  file_id               number(16),
  dst_bin               varchar2(6),
  src_bin               varchar2(6),
  action_code           varchar2(1),
  counter_currency_code varchar2(3),
  base_currency_code    varchar2(3),
  effective_date        date,
  buy_rate              number(18,12),
  sell_rate             number(18,12)
)
/
-- add comments to the columns 
comment on column vis_currency_rate.id
  is 'Primary key'
/  
comment on column vis_currency_rate.file_id
  is 'File id of the visa clearing file'
/  
comment on column vis_currency_rate.dst_bin
  is 'The bin to which a BASE II transaction message is sent'
/  
comment on column vis_currency_rate.src_bin
  is 'The bin from which a BASE II transaction message is sent. This field must contain 400020'
/  
comment on column vis_currency_rate.action_code
  is 'Action code'
/  
comment on column vis_currency_rate.counter_currency_code
  is 'ISO numeric currency code of the counter currency'    
/  
comment on column vis_currency_rate.base_currency_code
  is 'ISO numeric currency code of the base currency'
/  
comment on column vis_currency_rate.buy_rate
  is 'The number of units of base currency required to buy one unit of counter currency'
/  
comment on column vis_currency_rate.sell_rate
  is 'The number of units of base currency received from selling one unit of counter currency'
/  
 