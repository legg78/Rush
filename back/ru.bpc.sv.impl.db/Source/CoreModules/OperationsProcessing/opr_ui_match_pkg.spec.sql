create or replace package opr_ui_match_pkg is

/*
 * Add conditions for matching
 * @param o_id                  Association identifier
 * @param o_seqnum              Sequence number
 * @param i_inst_id             Owner institution identifier
 * @param i_lang                Descriptions language
 * @param i_name                Name condition
 * @param i_condition           Condition (as SQL where clause part)
 */  
    procedure add_match_condition (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_condition           in com_api_type_pkg.t_full_desc
    );

/*
 * Modify conditions for matching
 * @param i_id                  Association identifier
 * @param io_seqnum             Sequence number
 * @param i_lang                Descriptions language
 * @param i_name                Name condition
 * @param i_condition           Condition (as SQL where clause part)
 */  
    procedure modify_match_condition (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_condition           in com_api_type_pkg.t_full_desc
    );

/*
 * Remove conditions for matching
 * @param i_id                  Association identifier
 * @param i_seqnum              Sequence number
 */  
    procedure remove_match_condition (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

/*
 * Add matching level
 * @param o_id                  Matching level identifier
 * @param o_seqnum              Sequence number
 * @param i_inst_id             Owner institution identifier
 * @param i_lang                Descriptions language
 * @param i_name                Name condition
 * @param i_priority            Priority of level within institution
 */  
    procedure add_match_level (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_priority            in com_api_type_pkg.t_tiny_id
    );

/*
 * Modify matching level
 * @param i_id                  Matching level identifier
 * @param io_seqnum             Sequence number
 * @param i_lang                Descriptions language
 * @param i_name                Name condition
 * @param i_priority            Priority of level within institution
 */  
    procedure modify_match_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_priority            in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove matching level
 * @param i_id                  Matching level identifier
 * @param i_seqnum              Sequence number
 */  
    procedure remove_match_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

/*
 * Include condition in level
 * @param o_id                  Matching level condition identifier
 * @param o_seqnum              Sequence number
 * @param i_condition_id        Condition identifier
 * @param i_level_id            Matching level identifier
 */  
    procedure include_condition_in_level (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_level_id            in com_api_type_pkg.t_tiny_id
        , i_condition_id        in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove condition from level
 * @param i_id                  Matching level condition identifier
 * @param i_seqnum              Sequence number
 */  
    procedure remove_condition_from_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end;
/
