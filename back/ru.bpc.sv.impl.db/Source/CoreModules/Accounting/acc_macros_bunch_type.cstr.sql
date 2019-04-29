alter table acc_macros_bunch_type add constraint acc_macros_bunch_type_pk primary key (
    id
)
/

create unique index acc_macros_bunch_type_uk on acc_macros_bunch_type (
    macros_type_id
  , bunch_type_id
  , inst_id
)
/
drop index acc_macros_bunch_type_uk
/
