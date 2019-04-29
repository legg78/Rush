create or replace package body cst_api_operation_pkg is
/*********************************************************
 *  Custom operation processing API <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 04.12.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_api_operation_pkg <br />
 *  @headcom
 **********************************************************/

    function build_operation_desc (
        i_operation_id           in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_text is
        l_operation_desc         com_api_type_pkg.t_text;
    begin
        return l_operation_desc;
    end;
    
    procedure define_network(
        i_msg_type              in      com_api_type_pkg.t_dict_value
      , i_oper_type             in      com_api_type_pkg.t_dict_value
      , i_party_type            in      com_api_type_pkg.t_dict_value
      , i_host_date             in      date
      , io_network_id           in out  com_api_type_pkg.t_tiny_id
      , io_inst_id              in out  com_api_type_pkg.t_inst_id
      , o_host_id                  out  com_api_type_pkg.t_tiny_id
      , i_client_id_type        in      com_api_type_pkg.t_dict_value
      , i_client_id_value       in      com_api_type_pkg.t_name
      , io_customer_id          in out  com_api_type_pkg.t_medium_id
      , io_split_hash           in out  com_api_type_pkg.t_tiny_id
      , i_payment_host_id       in      com_api_type_pkg.t_tiny_id
      , i_payment_order_id      in      com_api_type_pkg.t_long_id
    ) is
    begin
        null;
    end;
end;
/
