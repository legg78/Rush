alter table com_dictionary add (
    constraint com_dictionary_pk primary key (id),
    constraint com_dictionary_uk unique (dict, code)
)
/