alter table com_i18n add (
    constraint com_i18n_pk primary key (id), 
    constraint com_i18n_uk unique (table_name, object_id, column_name, lang)
)
/