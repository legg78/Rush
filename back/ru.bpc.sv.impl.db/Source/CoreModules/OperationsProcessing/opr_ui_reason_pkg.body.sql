create or replace package body opr_ui_reason_pkg is
/************************************************************
 * User interface for mapping of operation reason <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 09.08.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: opr_ui_reason_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_reason (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_reason_dict         in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := opr_reason_seq.nextval;
        o_seqnum := 1;
    
        insert into opr_reason_vw (
            id
            , seqnum
            , oper_type
            , reason_dict
        ) values (
            o_id
            , o_seqnum
            , i_oper_type
            , case when nvl(length(i_reason_dict), 0) > 5 then substr(i_reason_dict, 5) else i_reason_dict end
        );
    end;

    procedure modify_reason (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_reason_dict         in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            opr_reason_vw
        set
            seqnum = io_seqnum
            , oper_type = i_oper_type
            , reason_dict = case when nvl(length(i_reason_dict), 0) > 5 then substr(i_reason_dict, 5) else i_reason_dict end
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove_reason (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_reason_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            opr_reason_vw
        where
            id = i_id;
    end;

end; 
/
