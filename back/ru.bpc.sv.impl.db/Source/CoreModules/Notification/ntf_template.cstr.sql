alter table ntf_template add (
    constraint ntf_template_pk primary key (id)
  , constraint ntf_template_uk unique (notif_id, channel_id, lang)
)
/
