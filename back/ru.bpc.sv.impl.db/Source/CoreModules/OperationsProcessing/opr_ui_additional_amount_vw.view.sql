create or replace force view opr_ui_additional_amount_vw
as
select a.oper_id
     , a.amount_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => a.amount_type
         , i_lang    => l.lang
       ) as amount_type_desc
     , a.currency
     , a.amount
     , l.lang
  from opr_additional_amount a
     , com_language_vw l
 where l.lang = com_ui_user_env_pkg.get_user_lang
/
