create index cln_case_customer_id_ndx on cln_case (customer_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index cln_case_user_id_ndx on cln_case (user_id)
/****************** partition start ********************
    global
******************** partition end ********************/
/
create unique index cln_case_case_nmbr_inst_id_ndx on cln_case (case_number, inst_id)
/****************** partition start ********************
    global
******************** partition end ********************/
/
