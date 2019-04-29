create or replace package utl_api_report_pkg is

    procedure run_report_dict (
        o_xml                       out clob
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_module_code             in com_api_type_pkg.t_module_code := null
        , i_table_name              in com_api_type_pkg.t_name := null
        , i_is_constraint           in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
        , i_is_index                in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );

procedure run_report_rep
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_tag_id       in com_api_type_pkg.t_tiny_id  default null
  ) ;

end;
/


