alter table rul_algorithm add (constraint rul_algorithm_pk primary key (id))
/
alter table rul_algorithm add constraint rul_algorithm_uk unique(algorithm, entry_point)
/
