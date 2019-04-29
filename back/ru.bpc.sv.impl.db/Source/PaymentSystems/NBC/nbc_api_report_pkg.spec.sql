create or replace package nbc_api_report_pkg is

procedure detail_report (
    o_xml                out       clob
    , i_inst_id          in        com_api_type_pkg.t_inst_id    default null
    , i_start_date       in        date                          default null 
    , i_end_date         in        date                          default null
    , i_mode             in        com_api_type_pkg.t_dict_value  
    , i_lang             in        com_api_type_pkg.t_dict_value
);

procedure total_report (
    o_xml                out       clob
    , i_inst_id          in        com_api_type_pkg.t_inst_id  default null
    , i_start_date       in        date                        default null 
    , i_end_date         in        date                        default null 
    , i_mode             in        com_api_type_pkg.t_dict_value  
    , i_lang             in        com_api_type_pkg.t_dict_value
);

end nbc_api_report_pkg;
/
