create or replace package net_ui_card_type_pkg is
/*********************************************************
*  UI for card types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 31.05.2010 <br />
*  Last changed by $Author: kopachev $ <br />
*  $LastChangedDate:: 2011-02-11 14:17:58 +0300#$ <br />
*  Revision: $LastChangedRevision: 8057 $ <br />
*  Module: NET_UI_CARD_TYPE_PKG <br />
*  @headcom
**********************************************************/
/*
 * Register new card type
 * @param o_id                  Card type identificator
 * @param o_seqnum              Sequence number
 * @param i_standard_id         Parent card type identifier
 * @param i_network_id          Network identifier
 * @param i_lang                Descriptions language
 * @param i_name                Card type name
 */  
procedure add (
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_parent_type_id      in     com_api_type_pkg.t_tiny_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_name                in     com_api_type_pkg.t_name
  , i_is_virtual          in     com_api_type_pkg.t_boolean     default null
);

/*
 * Modify card type
 * @param i_id                  Card type identificator
 * @param io_seqnum             Sequence number
 * @param i_parent_type_id      Parent card type identifier
 * @param i_network_id          Network identifier
 * @param i_lang                Descriptions language
 * @param i_name                Card type name
*/  
procedure modify (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_parent_type_id      in     com_api_type_pkg.t_tiny_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_name                in     com_api_type_pkg.t_name
  , i_is_virtual          in     com_api_type_pkg.t_boolean     default null
);

/*
 * Remove card type
 * @param i_id                  Card type identificator
 * @param i_seqnum              Sequence number
 */  
procedure remove (
    i_id                  in com_api_type_pkg.t_tiny_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
);

end; 
/
