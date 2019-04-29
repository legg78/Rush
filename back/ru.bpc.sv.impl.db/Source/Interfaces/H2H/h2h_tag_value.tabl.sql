create table h2h_tag_value(
    id                number(16)        not null
  , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual
  , auth_id           number(16)        not null
  , tag_id            number(8)         not null
  , tag_value         varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
    partition h2h_tag_value_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/
comment on table h2h_tag_value is 'H2H tag values'
/
comment on column h2h_tag_value.id is 'Identifier. Primary key'
/
comment on column h2h_tag_value.auth_id is 'Authorization identifier'
/
comment on column h2h_tag_value.tag_id is 'Tag identifier'
/
comment on column h2h_tag_value.tag_value is 'Tag value'
/

drop table h2h_tag_value
/
create table h2h_tag_value(
    id                number(16)        not null
  , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual
  , fin_id            number(16)        not null
  , tag_id            number(8)         not null
  , tag_value         varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
    partition h2h_tag_value_p01 values less than (to_date('1-1-2019','DD-MM-YYYY'))
)
******************** partition end ********************/
/
comment on table h2h_tag_value is 'Host-to-host tag values'
/
comment on column h2h_tag_value.id is 'Identifier. Primary key'
/
comment on column h2h_tag_value.fin_id is 'Reference to host-to-host financial message'
/
comment on column h2h_tag_value.tag_id is 'Tag identifier, it is the reference to H2H_TAG.id'
/
comment on column h2h_tag_value.tag_value is 'Tag value'
/
