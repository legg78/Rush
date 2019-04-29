alter table cmn_standard add (constraint cmn_standard_pk primary key(id))
/

create unique index cmn_standard_uk on cmn_standard
(case when standard_type = 'STDT0201' then to_char(id,'TM9') else application_plugin end, standard_type)
/