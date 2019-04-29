create or replace force view vis_ui_vss6_vw as
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
     , proc_id
     , clear_bin
     , clear_currency
     , sttl_service
     , bus_mode
     , no_data
     , report_group
     , report_subgroup
     , rep_id_num
     , rep_id_sfx
     , sttl_date
     , report_date
     , fin_ind
     , clear_only
     , bus_tr_type
     , bus_tr_cycle
     , reversal
     , trans_dispos
     , trans_count
     , amount
     , summary_level
     , reimb_attr
     , inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => v.inst_id
                , i_lang        => l.lang
       ) inst_name
     , crs_date  
  from vis_vss6 v
     , com_language_vw l  
/
