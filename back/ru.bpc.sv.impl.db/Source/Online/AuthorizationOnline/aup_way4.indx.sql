create index aup_way4_ndx on aup_way4(
    trace
  , iso_msg_type
  , acq_inst_bin
  , refnum
  , auth_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index aup_way4_ndx2 on aup_way4(time_mark, iso_msg_type, acq_inst_bin, refnum)
/
create index aup_way4_ndx3 on aup_way4(trace, iso_msg_type, acq_inst_bin, refnum)
/

drop index aup_way4_ndx3
/

create index aup_way4_ext_ntwk_ref_ndx on aup_way4(ext_ntwk_ref, acq_inst_bin, refnum)
/
