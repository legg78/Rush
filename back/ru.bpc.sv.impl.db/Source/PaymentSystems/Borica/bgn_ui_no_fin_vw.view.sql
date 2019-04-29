create or replace force view bgn_ui_no_fin_vw as
  select  f.id
        , f.file_id
        , f.code
        , f.card_marker
        , f.product_name
        , f.oper_name
        , f.seq_number
        , f.ird
        , f.debit_count
        , f.debit_trans
        , f.debit_tax
        , f.debit_total
        , f.credit_count
        , f.credit_trans
        , f.credit_tax
        , f.credit_total
     from bgn_no_fin f
/
 