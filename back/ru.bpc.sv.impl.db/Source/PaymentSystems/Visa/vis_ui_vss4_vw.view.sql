create or replace force view vis_ui_vss4_vw as
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
     , clear_currency
     , bus_mode
     , no_data
     , report_group
     , report_subgroup
     , rep_id_num
     , rep_id_sfx
     , sttl_date
     , report_date
     , date_from
     , date_to
     , charge_type
     , bus_tr_type
     , bus_tr_cycle
     , revers_ind
     , return_ind
     , jurisdict
     , routing
     , src_country
     , dst_country
     , src_region
     , dst_region
     , fee_level
     , cr_db_net
     , summary_level
     , reimb_attr
     , currency_table_date
     , first_count
     , second_count
     , first_amount
     , second_amount
     , third_amount
     , fourth_amount
     , fifth_amount
     , inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => v.inst_id
                , i_lang        => l.lang
       ) inst_name
  from vis_vss4 v
     , com_language_vw l  
/
