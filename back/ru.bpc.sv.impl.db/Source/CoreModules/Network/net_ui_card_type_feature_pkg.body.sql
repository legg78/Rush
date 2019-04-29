create or replace package body net_ui_card_type_feature_pkg is
/************************************************************
 * User interface for NET card type feature <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.01.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: net_ui_card_type_feature_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_card_type_feature (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_card_feature            in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := net_card_type_feature_seq.nextval;
        o_seqnum := 1;
        
        insert into net_card_type_feature_vw (
            id
            , seqnum
            , card_type_id
            , card_feature
       ) values (
            o_id
            , o_seqnum
            , i_card_type_id
            , i_card_feature
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_CARD_TYPE_FEATURE'
            );
    end;

    procedure modify_card_type_feature (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_card_feature            in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            net_card_type_feature_vw
        set
            seqnum = io_seqnum
            , card_type_id = i_card_type_id
            , card_feature = i_card_feature
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_CARD_TYPE_FEATURE'
            );
    end;

    procedure remove_card_type_feature (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            net_card_type_feature_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        -- delete element
        delete from
            net_card_type_feature_vw
        where
            id = i_id;
    
    end;

end;
/
