create or replace force view tie_ui_fin_msg_vw as
select decode(
           com_api_label_pkg.get_label_text('TIE_FIN_'||c.column_name, l.lang)
         , 'TIE_FIN_'||c.column_name
         , substr(c.comments, 1, instr(c.comments || '.', '.'))
         , com_api_label_pkg.get_label_text('TIE_FIN_'||c.column_name, l.lang)
       )                  as name
     , cl.data_type       as data_type
     , case c.column_name
           when 'STATUS'                         then a.status
           when 'MTID'                           then a.mtid
           when 'ISS_CMI'                        then a.iss_cmi
           when 'SEND_CMI'                       then a.send_cmi
           when 'SETTL_CMI'                      then a.settl_cmi
           when 'CLEARING_GROUP'                 then a.clearing_group
           when 'SENDER_ICA'                     then a.sender_ica
           when 'RECEIVER_ICA'                   then a.receiver_ica
           when 'MERCHANT'                       then a.merchant
           when 'BATCH_NR'                       then a.batch_nr
           when 'SLIP_NR'                        then a.slip_nr
           when 'CARD'                           then iss_api_card_pkg.get_card_mask(fc.card_number)
           when 'TRAN_TYPE'                      then a.tran_type
           when 'APPR_CODE'                      then a.appr_code
           when 'APPR_SRC'                       then a.appr_src
           when 'STAN'                           then a.stan
           when 'REF_NUMBER'                     then a.ref_number
           when 'CURRENCY'                       then a.currency
           when 'SBNK_CCY'                       then a.sbnk_ccy
           when 'IBNK_CCY'                       then a.ibnk_ccy
           when 'ABVR_NAME'                      then a.abvr_name
           when 'CITY'                           then a.city
           when 'COUNTRY'                        then a.country
           when 'POINT_CODE'                     then a.point_code
           when 'MCC_CODE'                       then a.mcc_code
           when 'TERMINAL'                       then a.terminal
           when 'SETTL_NR'                       then a.settl_nr
           when 'ACQREF_NR'                      then a.acqref_nr
           when 'SOURCE_ALGORITHM'               then a.source_algorithm
           when 'ERR_CODE'                       then a.err_code
           when 'TERM_NR'                        then a.term_nr
           when 'TRAN_INFO'                      then a.tran_info
           when 'PRNK_CCY'                       then a.prnk_ccy
           when 'REGION'                         then a.region
           when 'CARD_TYPE'                      then a.card_type
           when 'PROC_CLASS'                     then a.proc_class
           when 'MSG_TYPE'                       then a.msg_type
           when 'ORG_MSG_TYPE'                   then a.org_msg_type
           when 'PROC_CODE'                      then a.proc_code
           when 'MSG_CATEGORY'                   then a.msg_category
           when 'MERCHANT_CODE'                  then a.merchant_code
           when 'MOTO_IND'                       then a.moto_ind
           when 'SUSP_STATUS'                    then a.susp_status
           when 'TRANSACT_ROW'                   then a.transact_row
           when 'AUTHORIZ_ROW'                   then a.authoriz_row
           when 'FLD_043'                        then a.fld_043
           when 'FLD_098'                        then a.fld_098
           when 'FLD_102'                        then a.fld_102
           when 'FLD_103'                        then a.fld_103
           when 'FLD_104'                        then a.fld_104
           when 'FLD_039'                        then a.fld_039
           when 'FLD_SH6'                        then a.fld_sh6
           when 'FLD_040'                        then a.fld_040
           when 'FLD_123_1'                      then a.fld_123_1
           when 'EPI_42_48'                      then a.epi_42_48
           when 'FLD_003'                        then a.fld_003
           when 'ACCOUNT_NR'                     then a.account_nr
           when 'EPI_42_48_FULL'                 then a.epi_42_48_full
           when 'OTHER_CODE'                     then a.other_code
           when 'FLD_095'                        then a.fld_095
           when 'FLD_055'                        then a.fld_055
           when 'FLD_126'                        then a.fld_126
           else to_char(null)
       end                as column_char_value
     , case c.column_name
           when 'ID'                             then a.id
           when 'SPLIT_HASH'                     then a.split_hash
           when 'INST_ID'                        then a.inst_id
           when 'NETWORK_ID'                     then a.network_id
           when 'FILE_ID'                        then a.file_id
           when 'IS_INCOMING'                    then a.is_incoming
           when 'IS_REVERSAL'                    then a.is_reversal
           when 'IS_INVALID'                     then a.is_invalid
           when 'IS_REJECTED'                    then a.is_rejected
           when 'REJECT_ID'                      then a.reject_id
           when 'DISPUTE_ID'                     then a.dispute_id
           when 'IMPACT'                         then a.impact
           when 'REC_CENTR'                      then a.rec_centr
           when 'SEND_CENTR'                     then a.send_centr
           when 'ACQ_BANK'                       then a.acq_bank
           when 'ACQ_BRANCH'                     then a.acq_branch
           when 'MEMBER'                         then a.member
           when 'AMOUNT'                         then a.amount
           when 'CASH_BACK'                      then a.cash_back
           when 'FEE'                            then a.fee
           when 'CCY_EXP'                        then a.ccy_exp
           when 'SB_AMOUNT'                      then a.sb_amount
           when 'SB_CSHBACK'                     then a.sb_cshback
           when 'SB_FEE'                         then a.sb_fee
           when 'SB_CCYEXP'                      then a.sb_ccyexp
           when 'SB_CNVRATE'                     then a.sb_cnvrate
           when 'I_AMOUNT'                       then a.i_amount
           when 'I_CSHBACK'                      then a.i_cshback
           when 'I_FEE'                          then a.i_fee
           when 'I_CCYEXP'                       then a.i_ccyexp
           when 'I_CNVRATE'                      then a.i_cnvrate
           when 'BATCH_ID'                       then a.batch_id
           when 'CLR_FILE_ID'                    then a.clr_file_id
           when 'MS_NUMBER'                      then a.ms_number
           when 'ECMC_FEE'                       then a.ecmc_fee
           when 'PR_AMOUNT'                      then a.pr_amount
           when 'PR_CSHBACK'                     then a.pr_cshback
           when 'PR_FEE'                         then a.pr_fee
           when 'PR_CCYEXP'                      then a.pr_ccyexp
           when 'PR_CNVRATE'                     then a.pr_cnvrate
           when 'CARD_SEQ_NR'                    then a.card_seq_nr
           when 'TR_FEE'                         then a.tr_fee
           when 'MSC'                            then a.msc
           when 'OTHER_FEE1'                     then a.other_fee1
           when 'OTHER_FEE2'                     then a.other_fee2
           when 'OTHER_FEE3'                     then a.other_fee3
           when 'OTHER_FEE4'                     then a.other_fee4
           when 'OTHER_FEE5'                     then a.other_fee5
           when 'FLD_030A'                       then a.fld_030a
           else to_number(null)
       end                as column_number_value
     , case c.column_name
           when 'EXP_DATE'                       then a.exp_date
           when 'TRAN_DATE_TIME'                 then a.tran_date_time
           when 'SB_CNVDATE'                     then a.sb_cnvdate
           when 'I_CNVDATE'                      then a.i_cnvdate
           when 'SETTL_DATE'                     then a.settl_date
           when 'FILE_DATE'                      then a.file_date
           when 'PR_CNVDATE'                     then a.pr_cnvdate
           when 'BATCH_DATE'                     then a.batch_date
           when 'FLD_015'                        then a.fld_015
           when 'AUDIT_DATE'                     then a.audit_date
           else to_date(null)
       end                as column_date_value
     , cl.column_id       as column_order
     , a.id               as oper_id
     , l.lang
     , 1*10               as column_level
     , null               as lov_id
     , null               as dict_code
     , to_number(null)    as tech_id
  from tie_fin           a
     , tie_card         fc
     , com_language_vw   l
     , all_col_comments  c
     , all_tab_columns  cl
 where c.table_name = 'TIE_FIN'
   and c.owner = user
   and cl.owner = user
   and fc.id    = a.id
   and cl.table_name = 'TIE_FIN'
   and cl.column_name = c.column_name
   and cl.data_type in ('VARCHAR2', 'NUMBER', 'DATE')
   and c.column_name not in ('SPLIT_HASH')
/
