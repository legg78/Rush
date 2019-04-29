create table cst_bof_gim_retrieval(
   id                           number(16)
 , file_id                      number(16)
 , iss_inst_id                  number(4)
 , acq_inst_id                  number(4)
 , document_type                varchar2(1)
 , card_iss_ref_num             varchar2(9)
 , cancellation_ind             varchar2(1)
 , potential_chback_reason_code varchar2(2)
 , response_type                varchar2(1)
)
/

comment on table cst_bof_gim_retrieval is 'Financial Messages Table. This contains retrieval request records TC 51, 52, 53.'
/
comment on column cst_bof_gim_retrieval.id is 'Primary Key.'
/
comment on column cst_bof_gim_retrieval.file_id is 'Reference to clearing file.'
/

alter table cst_bof_gim_retrieval drop column document_type
/
alter table cst_bof_gim_retrieval add document_type number(1)
/
alter table cst_bof_gim_retrieval drop column response_type
/
alter table cst_bof_gim_retrieval add response_type number(1)
/
