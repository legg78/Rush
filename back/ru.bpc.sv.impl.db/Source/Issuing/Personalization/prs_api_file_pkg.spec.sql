create or replace package prs_api_file_pkg is
/************************************************************
 * API for files files <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_file_pkg <br />
 * @headcom
 ************************************************************/
/*
 * Clear global data
 */
    procedure clear_global_data;

/*
 * Close session files
 */
    procedure close_session_file;

/*
 * Sequence number of the embossing record within the file.
 * @param  i_perso_rec      - Personalization record
 * @param  i_format_id      - Format identifier
 * @param  i_entity_type    - Entity type
 * @param  i_file_type      - File type
 */ 
    function get_record_number (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_long_id;

/*
 * Register session file
 * @param  i_raw_data       - Raw data
 * @param  i_perso_rec      - Personalization record
 * @param  i_format_id      - Format identifier
 * @param  i_entity_type    - Entity type
 * @param  i_file_type      - File type
 */
    function register_session_file (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_long_id;
    
/*
 * Put file records
 * @param  i_raw_data       - Raw data
 * @param  i_perso_rec      - Personalization record
 * @param  i_format_id      - Format identifier
 * @param  i_entity_type    - Entity type
 * @param  i_file_type      - File type
 */
    procedure put_records (
        i_raw_data              in raw
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value := null
    );

end; 
/
