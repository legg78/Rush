create or replace package dsp_ui_scale_selection_pkg as
/*********************************************************
 *  UI dispute scale type selection <br/>
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 25.05.2017 <br/>
 *  Module: DSP_UI_SCALE_SELECTION_PKG <br/>
 *  @headcom
 **********************************************************/

/*
 * Add new selection of a dispute scale type.
 * @i_mod_id    - modifier should be from a scale of type SCTPDCNS.
 */
procedure add(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_scale_type            in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_init_rule_id          in     com_api_type_pkg.t_tiny_id
  , i_label                 in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_scale_type            in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_init_rule_id          in     com_api_type_pkg.t_tiny_id
  , i_label                 in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , i_seqnum                in     com_api_type_pkg.t_seqnum
);

end;
/
