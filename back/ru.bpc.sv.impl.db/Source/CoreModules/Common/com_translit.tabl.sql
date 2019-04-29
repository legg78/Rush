create table com_translit(
    id        number not null
  , lang      varchar2(8)
  , char_from varchar2(6)
  , char_to   varchar2(6)
)
/

comment on table com_translit is 'Translit dictionary'
/
comment on column com_translit.id is 'Primary key'
/
comment on column com_translit.lang is 'Language'
/
comment on column com_translit.char_from is 'National chars'
/
comment on column com_translit.char_to is 'Latin chars'
/
create table com_translit_tmp as select * from com_translit
/
truncate table com_translit
/
alter table com_translit modify (id number(8, 0) )
/
insert into com_translit select * from com_translit_tmp
/
drop table com_translit_tmp
/
