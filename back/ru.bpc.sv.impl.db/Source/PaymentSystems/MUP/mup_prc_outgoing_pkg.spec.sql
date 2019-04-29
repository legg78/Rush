create or replace package mup_prc_outgoing_pkg is

    procedure upload (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id     := null
      , i_charset               in com_api_type_pkg.t_oracle_name := null
      , i_use_inst              in com_api_type_pkg.t_dict_value  := null
      , i_start_date            in date default null
      , i_end_date              in date default null
      , i_include_affiliate     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_collection_only       in com_api_type_pkg.t_boolean     := null
    );

end;
/
