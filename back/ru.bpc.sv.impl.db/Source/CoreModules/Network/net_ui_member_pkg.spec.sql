create or replace package net_ui_member_pkg is
/*********************************************************
 *  Interface for Network members and hosts  <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 01.06.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: net_ui_member_pkg  <br />
 *  @headcom
 **********************************************************/

/*
 * Register new networks member institutions
 * @param o_id                  Networks member institutions identificator
 * @param o_seqnum              Sequence number
 * @param i_inst_id             Institution identifier
 * @param i_network_id          Network identifier
 * @param i_online_standard_id  Standard of online interaction
 * @param i_offline_standard_id Standard of offline interaction
 * @param i_participant_type    Host participant type
 */
procedure add (
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id
) ;

/*
 * Remove networks member institutions
 * @param i_id                  Networks member institutions identificator
 * @param i_seqnum              Sequence number
 */
procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
);

/*
 * Register host
 * @param i_id                  Host identificator
 * @param io_seqnum             Sequence number
 * @param i_online_standard_id  Online standard_id identifier
 * @param i_offline_standard_id Offline standard identifier
 * @param i_lang                Language
 * @param i_description         Description
 * @param i_status              Status
 * @param i_scale_id            Scale identifier
 */
procedure add_host (
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_online_standard_id    in      com_api_type_pkg.t_tiny_id
  , i_offline_standard_id   in      com_api_type_pkg.t_tiny_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_status                in      com_api_type_pkg.t_dict_value := 'HSST0001'
  , i_scale_id              in      com_api_type_pkg.t_tiny_id := null
);

/*
 * Modify host
 * @param i_id                  Host identificator
 * @param io_seqnum             Sequence number
 * @param i_online_standard_id  Online standard_id identifier
 * @param i_offline_standard_id Offline standard identifier
 * @param i_lang                Language
 * @param i_description         Description
 * @param i_status              Status
 * @param i_scale_id            Scale identifier
 */
procedure modify_host (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_online_standard_id    in      com_api_type_pkg.t_tiny_id
  , i_offline_standard_id   in      com_api_type_pkg.t_tiny_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_status                in      com_api_type_pkg.t_dict_value := 'HSST0001'
  , i_scale_id              in      com_api_type_pkg.t_tiny_id := null
);

/*
 * Remove host
 * @param i_id                  Host identificator
 * @param io_seqnum             Sequence number
 */
procedure remove_host (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
);

end;
/
