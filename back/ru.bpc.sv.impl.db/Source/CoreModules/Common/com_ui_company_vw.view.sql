create or replace force view com_ui_company_vw as
select a.id
     , a.embossed_name
     , a.incorp_form
     , a.seqnum
     , a.inst_id
     , b.lang
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'com_company'
         , i_column_name => 'label'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) as label
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'com_company'
         , i_column_name => 'description'
         , i_object_id   => a.id
         , i_lang        => b.lang
       )  as description
from  com_company a
    , com_language_vw b
where a.inst_id = get_user_sandbox
/
