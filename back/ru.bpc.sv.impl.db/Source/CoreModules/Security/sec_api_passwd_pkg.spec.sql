create or replace package sec_api_passwd_pkg as 
/*********************************************************
*  API for generate passwords <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 18.02.2013 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: SEC_API_PASSWD_PKG <br />
*  @headcom
**********************************************************/
function generate_otp(
    i_passwd_type         in     com_api_type_pkg.t_dict_value
  , i_length              in     com_api_type_pkg.t_tiny_id    
) return com_api_type_pkg.t_name;

function generate_otp(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_name;

procedure send_onetime_password(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_otp                   out com_api_type_pkg.t_name
);

procedure get_onetime_password(
    i_event_type          in     com_api_type_pkg.t_dict_value
  , i_address             in     com_api_type_pkg.t_full_desc
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_otp                 in     com_api_type_pkg.t_name        default null
);

procedure send_onetime_password(
    i_card_number          in    com_api_type_pkg.t_card_number
  , i_otp                  in    com_api_type_pkg.t_name
  , o_delivery_address     out   com_api_type_pkg.t_full_desc
);

end sec_api_passwd_pkg;
/
