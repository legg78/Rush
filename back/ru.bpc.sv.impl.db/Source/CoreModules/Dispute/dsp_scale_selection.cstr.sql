alter table dsp_scale_selection add constraint dsp_scale_selection_pk primary key (id)
/
alter table dsp_scale_selection add constraint dsp_scale_selection_uk unique (scale_type, mod_id)
/
