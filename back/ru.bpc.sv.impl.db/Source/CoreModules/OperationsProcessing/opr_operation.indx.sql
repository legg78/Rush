create index opr_operation_OPST0100_ndx on opr_operation (
    decode(status, 'OPST0100', 'OPST0100')
)
/

create index opr_operation_MTST0200_ndx on opr_operation (
    decode(match_status, 'MTST0200', match_status, null)
)
/

create index opr_oper_unhold_status_ndx on opr_operation (
    decode(status, 'OPST0800', unhold_date, null)
)
/

create index opr_oper_payment_order_ndx on opr_operation (
    payment_order_id
)
/

create index opr_oper_originator_refnum_ndx on opr_operation (originator_refnum)
/


create index opr_operation_MTST0200_6_ndx on opr_operation (decode(match_status, 'MTST0200', match_status, 'MTST0600', match_status, null))
/


drop index opr_oper_unhold_status_ndx
/
create index opr_oper_unhold_status_ndx on opr_operation (decode(status,'OPST0800',unhold_date,'OPST0850',unhold_date,NULL))
/
create index opr_oper_network_refnum_ndx on opr_operation (network_refnum)
/

drop index opr_operation_MTST0200_ndx
/
drop index opr_operation_MTST0200_6_ndx
/
create index opr_operation_match_ndx on opr_operation (decode(match_status, 'MTST0200', match_status, 'MTST0600', match_status, null))
/
create index opr_oper_original_id_ndx on opr_operation(original_id)
/
create index opr_oper_inc_file_id_ndx on opr_operation(incom_sess_file_id)
/
create index opr_oper_session_id_ndx on opr_operation(session_id)
/
create index opr_oper_match_id_ndx on opr_operation(match_id)
/
create index opr_oper_dispute_id_ndx on opr_operation(dispute_id)
/
create index opr_oper_date_ndx on opr_operation (trunc(oper_date))
/
drop index opr_operation_OPST0100_ndx
/
create index opr_operation_OPST0100_ndx on opr_operation (decode(status, 'OPST0100', 'OPST0100', null))
/
