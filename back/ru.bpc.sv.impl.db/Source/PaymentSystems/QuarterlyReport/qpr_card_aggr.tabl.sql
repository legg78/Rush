create table qpr_card_aggr(
    card_id number(12)
  , report_date date
)
/
comment on table qpr_card_aggr  is 'Aggregate card data for quarter reports'
/
comment on column qpr_card_aggr.card_id is 'Card identifier'
/
comment on column qpr_card_aggr.report_date is 'First day of quarter'
/
alter table qpr_card_aggr add (card_type_id number(4))
/
comment on column qpr_card_aggr.card_type_id is 'Card type identifier'
/
