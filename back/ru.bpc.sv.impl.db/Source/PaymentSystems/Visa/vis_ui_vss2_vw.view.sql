create or replace force view vis_ui_vss2_vw as
select id
     , file_id
     , record_number
     , status
     , get_article_text ( i_article => v.status
                        , i_lang    => l.lang
       ) status_desc
     , dst_bin
     , src_bin
     , sre_id
     , up_sre_id
     , funds_id
     , sttl_service
     , sttl_currency
     , no_data
     , report_group
     , report_subgroup
     , rep_id_num
     , rep_id_sfx
     , sttl_date
     , report_date
     , date_from
     , date_to
     , amount_type
     , bus_mode
     , trans_count
     , credit_amount
     , debit_amount
     , net_amount
     , reimb_attr
     , inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => v.inst_id
                , i_lang        => l.lang
       ) inst_name
  from vis_vss2 v
     , com_language_vw l  
/
