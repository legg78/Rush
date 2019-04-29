create or replace package amx_cst_fin_message_pkg as
/*********************************************************
 *  The package with user-exits for Amex financial processing <br />
 *
 *  Created by Bondarets A. (bondarets@bpcbt.com) at 04.09.2018 <br />
 *  Last changed by $Author: bondarets $ <br />
 *  $LastChangedDate: 2018-09-04 14:00:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: amx_cst_dispute_pkg <br />
 *  @headcom
 **********************************************************/

procedure process_auth (
    io_fin_rec            in out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_auth_rec            in     aut_api_type_pkg.t_auth_rec
  , i_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id    := null
  , i_network_id          in     com_api_type_pkg.t_tiny_id    := null
  , i_status              in     com_api_type_pkg.t_dict_value := null
  , i_collection_only     in     com_api_type_pkg.t_boolean    := null
);

end;
/

