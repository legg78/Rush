create or replace package pmo_api_provider_pkg as
/************************************************************
 * API for service provider<br />
 * Created by Alalykin A.(alalykin@bpc.ru) at 07.06.2014  <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2014-06-06 17:20:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 36740 $ <br />
 * Module: PMO_API_PROVIDER_PKG <br />
 * @headcom
 ************************************************************/

/************************************************************
 * Returns TRUE if provider with the identifier <i_id> is actually a group provider.
 ************************************************************/
function is_provider_group(
    i_id                in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

/************************************************************
 * Returns TRUE if provider <i_id> exists.
 ************************************************************/
function provider_exists(
    i_id                in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

/************************************************************
 * Clones all purposes and parameters from source provider to destination one (both of them should exist).
 * @param i_src_provider_id    source provider identifier
 * @param i_dst_provider_id    destination provider identifier (it should be created previously)
 * @throws e_application_error if source provider doesn't exist (a) or destination one has its own purposes or parameters (b)
 ************************************************************/
procedure clone_purposes_and_params(
    i_src_provider_id   in     com_api_type_pkg.t_short_id
  , i_dst_provider_id   in     com_api_type_pkg.t_short_id
);

function get_provider_id(
    i_provider_number       in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

function get_provider_id(
    i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

function get_purpose_id(
    i_purpose_number        in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

end;
/
