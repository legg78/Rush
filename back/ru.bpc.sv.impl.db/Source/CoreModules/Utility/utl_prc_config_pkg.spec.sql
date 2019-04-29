CREATE OR REPLACE package utl_prc_config_pkg as
/*********************************************************
*  Utility config process <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 21.06.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: UTL_PRC_CONFIG_PKG <br />
*  @headcom
**********************************************************/

procedure extract_config(
    i_config    in      com_api_type_pkg.t_dict_value
    , i_add_clear_statement in    com_api_type_pkg.t_boolean    default   com_api_const_pkg.FALSE
);

procedure load_config;

procedure upload_incremental_config(
    i_user_session_id    in     com_api_type_pkg.t_long_id
);

end utl_prc_config_pkg;
/