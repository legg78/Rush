alter table rul_mod_scale_param add constraint rul_mod_scale_param_pk primary key (
    id
)
/

alter table rul_mod_scale_param add constraint rul_mod_scape_param_uk unique(scale_id, param_id)
/
