create or replace package net_ui_card_type_feature_pkg is
/************************************************************
 * User interface for NET card type feature <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.01.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: net_ui_card_type_feature_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add card type feature
 * @param o_id                  - Feature identifier
 * @param o_seqnum              - Data version sequencial number
 * @param i_card_type_id        - Card type identifier
 * @param i_card_feature        - Card feature
 */
    procedure add_card_type_feature (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_card_feature            in com_api_type_pkg.t_dict_value
    );

/*
 * Modify card type feature
 * @param o_id                  - Feature identifier
 * @param io_seqnum             - Data version sequencial number
 * @param i_card_type_id        - Card type identifier
 * @param i_card_feature        - Card feature
 */
    procedure modify_card_type_feature (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_card_feature            in com_api_type_pkg.t_dict_value
    );

/*
 * Remove card type feature
 * @param i_id                  - Feature identifier
 * @param i_seqnum              - Data version sequencial number
 */
    procedure remove_card_type_feature (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
