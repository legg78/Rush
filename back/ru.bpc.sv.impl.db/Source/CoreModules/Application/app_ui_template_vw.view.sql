create or replace force view app_ui_template_vw as
   select a.id
        , a.appl_type
        , a.inst_id
        , com_api_i18n_pkg.get_text ('app_application',
                                     'label',
                                     a.id,
                                     l.lang)
        as template_name
        , a.product_id
        , a.flow_id
        , l.lang                                     
     from app_application a, com_language_vw l
    where a.is_template = 1
/	
