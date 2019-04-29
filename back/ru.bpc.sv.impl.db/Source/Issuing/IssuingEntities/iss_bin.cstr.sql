alter table iss_bin add (
    constraint iss_bin_pk primary key (id)
  , constraint iss_bin_uk unique (bin)
)
/
