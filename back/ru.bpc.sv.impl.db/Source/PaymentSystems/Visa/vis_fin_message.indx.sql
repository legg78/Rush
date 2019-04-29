create index vis_fin_message_VFMS0001_ndx on vis_fin_message (
    decode(status, 'VFMS0001', 'VFMS0001', null)
)
/
create index vis_fin_message_CLMS0010_ndx on vis_fin_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
drop index vis_fin_message_vfms0001_ndx
/

create index vis_fin_message_arn_ndx on vis_fin_message(arn)
/
 