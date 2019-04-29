create table cst_bmed_cbs_narrative (
    id                      number(4) not null
  , oper_type               varchar2(8)
  , sttl_type               varchar2(8)
  , transaction_type        varchar2(8)
  , fee_type                varchar2(8)
  , narrative_label_1       number(8)
  , narrative_label_2       number(8)
  , narrative_label_3       number(8)
)
/

comment on table cst_bmed_cbs_narrative is 'Narrative definition for the CBS outgoing file'
/

comment on column cst_bmed_cbs_narrative.id is 'Record identifier'
/
comment on column cst_bmed_cbs_narrative.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column cst_bmed_cbs_narrative.sttl_type is 'Settlement type (STTT dictionary)'
/
comment on column cst_bmed_cbs_narrative.transaction_type is 'Transaction type (TRNT dictionary)'
/
comment on column cst_bmed_cbs_narrative.fee_type is 'Fee type (FETP dictionary)'
/
comment on column cst_bmed_cbs_narrative.narrative_label_1 is 'Label identifier with narrative #1'
/
comment on column cst_bmed_cbs_narrative.narrative_label_2 is 'Label identifier with narrative #2'
/
comment on column cst_bmed_cbs_narrative.narrative_label_3 is 'Label identifier with narrative #3'
/
alter table cst_bmed_cbs_narrative add reference_value varchar2(10)
/
comment on column cst_bmed_cbs_narrative.reference_value is 'Reference data'
/
alter table cst_bmed_cbs_narrative add file_type varchar2(8)
/
comment on column cst_bmed_cbs_narrative.reference_value is 'File types of Bankmed Gateway (BMGW dictionary)'
/
alter table cst_bmed_cbs_narrative add need_aggregate number(1)
/
comment on column cst_bmed_cbs_narrative.need_aggregate is 'Need aggregate when 1 else 0 (BOOL dictionary)'
/
alter table cst_bmed_cbs_narrative modify (reference_value varchar2(200))
/
