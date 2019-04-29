create or replace package cst_pfp_api_report_pkg as

-- Welcome letter. i_object_id - card instance id
procedure welcome_letter (
    o_xml             out clob
  , i_lang         in     com_api_type_pkg.t_dict_value
  , i_object_id    in     com_api_type_pkg.t_medium_id
);

end cst_pfp_api_report_pkg;
/
