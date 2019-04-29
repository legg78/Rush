create or replace force view cpn_ui_campaign_vw as
select c.id
     , c.campaign_number
     , c.campaign_type
     , get_article_text(i_article => c.campaign_type) as campaign_type_desc
     , get_text(i_table_name  => 'cpn_campaign'
              , i_column_name => 'label'
              , i_object_id   => c.id
              , i_lang        => l.lang
       ) as name
     , c.start_date
     , c.end_date
     , c.inst_id
     , ost_ui_institution_pkg.get_inst_name(i_inst_id => c.inst_id, i_lang => l.lang) as institution_name
     , c.seqnum
     , get_text(i_table_name  => 'cpn_campaign'
              , i_column_name => 'description'
              , i_object_id   => c.id
              , i_lang        => l.lang
       ) as description
     , l.lang
     , c.cycle_id
  from cpn_campaign c
     , com_language_vw l
/
