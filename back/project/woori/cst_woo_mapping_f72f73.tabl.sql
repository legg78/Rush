create table cst_woo_mapping_f72f73 (
    id                          number(10)
    , file_date                 date
    , cif_num                   varchar2(20)
    , agent_id                  varchar2(10)
    , wdr_bank_code             varchar2(10)
    , wdr_acct_num              varchar2(30)
    , dep_bank_code             varchar2(10)
    , dep_acct_num              varchar2(30)
    , dep_curr_code             varchar2(3)
    , dep_amount                number(22,3)
    , brief_content             varchar2(200)
    , work_type                 varchar2(10)
    , err_code                  varchar2(10)
    , map_status                number(1)
)
/
alter table cst_woo_mapping_f72f73 add (seq_id varchar2(10))
/

comment on table cst_woo_mapping_f72f73 is 'Table reconcile between file 72 and file 73'
/
alter table cst_woo_mapping_f72f73 add sv_acct_num varchar2(30)
/
