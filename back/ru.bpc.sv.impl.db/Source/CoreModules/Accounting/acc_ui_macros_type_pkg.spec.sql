create or replace package acc_ui_macros_type_pkg is

procedure add (
    o_id                out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_bunch_type_id  in      com_api_type_pkg.t_tiny_id
  , i_status         in      com_api_type_pkg.t_dict_value
  , i_short_desc     in      com_api_type_pkg.t_short_desc
  , i_full_desc      in      com_api_type_pkg.t_full_desc    default null
  , i_details        in      com_api_type_pkg.t_full_desc    default null
  , i_lang           in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id        in      com_api_type_pkg.t_inst_id      default null
);
    
procedure modify (
    i_id             in      com_api_type_pkg.t_tiny_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_bunch_type_id  in      com_api_type_pkg.t_tiny_id
  , i_status         in      com_api_type_pkg.t_dict_value
  , i_short_desc     in      com_api_type_pkg.t_short_desc
  , i_full_desc      in      com_api_type_pkg.t_full_desc    default null
  , i_details        in      com_api_type_pkg.t_full_desc    default null
  , i_lang           in      com_api_type_pkg.t_dict_value   default null
);
    
procedure remove (
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_seqnum         in     com_api_type_pkg.t_seqnum
);

end;
/