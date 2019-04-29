create or replace package body opr_ui_participant_type_pkg as

procedure  add_participant_type (
    o_id                        out     com_api_type_pkg.t_tiny_id
    , i_oper_type           in          com_api_type_pkg.t_dict_value
    , i_participant_type    in          com_api_type_pkg.t_dict_value
) is
begin
    o_id := opr_participant_type_seq.nextval;
    
    insert into opr_participant_type_vw (
        id
        , oper_type
        , participant_type
    ) values (
        o_id
        , i_oper_type
        , i_participant_type
    );
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error     =>  'PARTICIPANT_WITH_OPER_ALREADY_EXIST'
        );
end;
  
procedure remove_participant_type (
    i_id    in  com_api_type_pkg.t_tiny_id
) is
begin
    delete from 
        opr_participant_type_vw 
    where 
        id = i_id;
end;
  
procedure remove_participant_type (
    i_oper_type             in  com_api_type_pkg.t_dict_value
    , i_participant_type    in  com_api_type_pkg.t_dict_value
) is
begin
    delete from 
        opr_participant_type_vw 
    where 
        oper_type               =   i_oper_type
        and participant_type    =   i_participant_type;
end;
    
end;
/