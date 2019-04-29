create or replace package gui_ui_wizard_pkg is
/************************************************************
 * User interface for graphical user interface <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 27.08.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2012-12-20 15:16:11 +0300#$ <br />
 * Revision: $LastChangedRevision: 26384 $ <br />
 * Module: gui_ui_wizard_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add wizard
 */
procedure add_wizard (
    o_id                      out com_api_type_pkg.t_tiny_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
  , i_maker_privilege_id   in     com_api_type_pkg.t_short_id default null
  , i_checker_privilege_id in     com_api_type_pkg.t_short_id default null
);
/*
 * Modify wizard
 */
procedure modify_wizard (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
  , i_maker_privilege_id   in     com_api_type_pkg.t_short_id default null
  , i_checker_privilege_id in     com_api_type_pkg.t_short_id default null
);

/*
 * Remove wizard
 */
procedure remove_wizard (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
);
    
/*
 * Add wizard step
 */    
procedure add_wizard_step (
    o_id                      out com_api_type_pkg.t_tiny_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_wizard_id            in     com_api_type_pkg.t_tiny_id
  , i_step_order           in     com_api_type_pkg.t_tiny_id
  , i_step_source          in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
);
/*
 * Modify wizard step
 */
procedure modify_wizard_step (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_wizard_id            in     com_api_type_pkg.t_tiny_id
  , i_step_order           in     com_api_type_pkg.t_tiny_id
  , i_step_source          in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
);

/*
 * Remove wizard step
 */
procedure remove_wizard_step (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
);

end;
/
