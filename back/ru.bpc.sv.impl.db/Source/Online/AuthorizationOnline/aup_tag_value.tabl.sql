create table aup_tag_value (
    auth_id        number(16) not null
    , part_key     as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tag_id       number(8) not null
    , tag_value    varchar2(200)
)
/****************** partition start ********************                            -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                 -- [@skip patch]
(                                                                                   -- [@skip patch]
    partition aup_tag_value_p01 values less than (to_date('1-1-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                   -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_tag_value is 'Table is used to store authorization tag values'
/
comment on column aup_tag_value.auth_id is 'Authorization identifier'
/
comment on column aup_tag_value.tag_id is 'Tag identifier'
/
comment on column aup_tag_value.tag_value is 'Tag value'
/
alter table aup_tag_value modify(tag_value varchar2(2000))
/
comment on column aup_tag_value.tag_id is 'Tag code (AUP_TAG.TAG)'
/
alter table aup_tag_value add (seq_number number(4))
/
comment on column aup_tag_value.seq_number is 'Sequential number of tag occurrence in auth_id'
/
