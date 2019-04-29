create or replace package cst_ibbl_prc_checkbook_pkg as

procedure process_checkbook_issuance(
    i_lang       in     com_api_type_pkg.t_dict_value   default get_user_lang
) ;

end cst_ibbl_prc_checkbook_pkg;
/
