alter table pmo_purpose_parameter add constraint pmo_purpose_parameter_pk primary key(id)
/
alter table pmo_purpose_parameter
add constraint pmo_purpose_parameter_uk unique(purpose_id, param_id)
using index
/
