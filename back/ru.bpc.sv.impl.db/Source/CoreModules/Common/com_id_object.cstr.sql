alter table com_id_object add (
    constraint com_id_object_pk primary key (id)
  , constraint com_id_object_uk unique (id_type, id_number, id_series)
)
/