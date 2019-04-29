create or replace force view vis_ui_vss1_vw as
select v.id
     , v.file_id
     , v.record_number
     , v.status
     , get_article_text ( i_article => v.status
                        , i_lang    => l.lang
       ) status_desc
     , v.dst_bin
     , v.src_bin
     , v.sre_id
     , v.sttl_service
     , v.report_date
     , v.sre_level
     , v.report_group
     , v.report_subgroup
     , v.rep_id_num
     , v.rep_id_sfx
     , v.sub_sre_id
     , v.sub_sre_name
     , v.funds_ind
     , v.entity_type
     , v.entity_id1
     , v.entity_id2
     , v.proc_sind
     , v.proc_id
     , v.network_sind
     , v.network_id
     , v.reimb_attr
     , v.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => v.inst_id
                , i_lang        => l.lang
       ) inst_name
     , l.lang
  from vis_vss1 v
     , com_language_vw l  
/
