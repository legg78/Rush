create or replace package prs_ui_blank_type_pkg is
/************************************************************
 * User interface for blank for card embossing <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_blank_type_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Register blank type
 */
procedure add_blank_type (
    o_id                out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_card_type_id   in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_name           in      com_api_type_pkg.t_name
);

/*
 * Modify blank type
 */
procedure modify_blank_type (
    i_id            in      com_api_type_pkg.t_tiny_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_card_type_id  in      com_api_type_pkg.t_tiny_id
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_name          in      com_api_type_pkg.t_name
);

/*
 * Remove blank type
 */
procedure remove_blank_type (
    i_id           in      com_api_type_pkg.t_tiny_id
  , i_seqnum       in      com_api_type_pkg.t_seqnum
);

end;
/
