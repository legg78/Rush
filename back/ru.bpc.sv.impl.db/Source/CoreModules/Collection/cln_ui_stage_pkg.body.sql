create or replace package body cln_ui_stage_pkg is

procedure add(
    o_id            out com_api_type_pkg.t_short_id
  , o_seqnum        out com_api_type_pkg.t_tiny_id
  , i_status     in     com_api_type_pkg.t_dict_value
  , i_resolution in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := cln_stage_seq.nextval;
    o_seqnum := 1;

    insert into cln_stage_vw(
        id
      , seqnum
      , status
      , resolution
    ) values (
        o_id
      , o_seqnum
      , i_status
      , i_resolution
    );
end;

procedure modify(    
    i_id         in     com_api_type_pkg.t_short_id
  , io_seqnum    in out com_api_type_pkg.t_tiny_id
  , i_status     in     com_api_type_pkg.t_dict_value
  , i_resolution in     com_api_type_pkg.t_dict_value
) is
begin
    update cln_stage
       set seqnum     = io_seqnum
         , status     = i_status
         , resolution = i_resolution
     where id         = i_id;

    io_seqnum := io_seqnum + 1;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error        => 'CLN_STAGE_ALREADY_EXIST'
          , i_env_param1   => i_status
          , i_env_param2   => i_resolution
        );
end;

procedure remove(    
    i_id         in     com_api_type_pkg.t_short_id
) is
begin
    update cln_stage_vw 
       set seqnum = seqnum + 1
     where id     = i_id;

    delete cln_stage_vw
     where id = i_id;
end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_status            in    com_api_type_pkg.t_dict_value
  , i_resolution        in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null
) is
begin
    cln_api_case_pkg.change_case_status(
        i_case_id           => i_case_id
      , i_status            => i_status
      , i_resolution        => i_resolution
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_split_hash        => i_split_hash
    );
end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_reason_code       in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null  
) is
begin
    cln_api_case_pkg.change_case_status(
        i_case_id           => i_case_id
      , i_reason_code       => i_reason_code
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_split_hash        => i_split_hash
    );
end;

end cln_ui_stage_pkg;
/
