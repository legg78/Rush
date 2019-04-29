create or replace force view com_rpt_company_r1_vw as
select id
     , seqnum
     , embossed_name
     , incorp_form
     , com_api_dictionary_pkg.get_article_text(
           i_article => incorp_form
       ) incorp_form_name
     , inst_id
  from com_company
/

