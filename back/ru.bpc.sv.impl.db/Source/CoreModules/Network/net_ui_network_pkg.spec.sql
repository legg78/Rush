create or replace package net_ui_network_pkg is
/**********************************************************
*  UI for networks <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 01.06.2010 <br />
*  Last changed by $Author: khougaev $ <br />
*  $LastChangedDate:: 2011-03-18 10:19:32 +0300#$ <br />
*  Revision: $LastChangedRevision: 8498 $ <br />
*  Module: NET_UI_NETWORK_PKG <br />
*  @headcom
***********************************************************/
/*
 * Register new network
 * @param o_id                      Network identificator
 * @param o_seqnum                  Sequence number
 * @param i_inst_id                 Primary Institution identifier associated with network
 * @param i_bin_table_scan_priority Order of scaning of bin table for bin
 * @param i_lang                    Descriptions language
 * @param i_name                    Network name
 * @param i_full_desc               Network description
 */  
procedure add (
    o_id                         out com_api_type_pkg.t_tiny_id
  , o_seqnum                     out com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_bin_table_scan_priority in     com_api_type_pkg.t_tiny_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_name                    in     com_api_type_pkg.t_name
  , i_full_desc               in     com_api_type_pkg.t_full_desc
);

/*
 * Modify network
 * @param i_id                      Network identificator
 * @param io_seqnum                 Sequence number
 * @param i_inst_id                 Primary Institution identifier associated with network
 * @param i_bin_table_scan_priority Order of scaning of bin table for bin
 * @param i_lang                    Descriptions language
 * @param i_name                    Network name
 * @param i_full_desc               Network description
 */
procedure modify (
    i_id                      in     com_api_type_pkg.t_tiny_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_bin_table_scan_priority in     com_api_type_pkg.t_tiny_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_name                    in     com_api_type_pkg.t_name
  , i_full_desc               in     com_api_type_pkg.t_full_desc
);

/*
 * Remove network
 * @param i_id                      Network identificator
 * @param i_seqnum                  Sequence number
 */
procedure remove (
    i_id                      in     com_api_type_pkg.t_tiny_id
  , i_seqnum                  in     com_api_type_pkg.t_seqnum
);

end;
/
