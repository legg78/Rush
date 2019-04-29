create or replace package sec_ui_rsa_certificate_pkg is
/************************************************************
 * User interface for RSA certificates <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_rsa_certificate_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add RSA certificate
 * @param  o_id                  - Certificate identifier
 * @param  o_seqnum              - Certificate sequence number
 * @param  i_certified_key_id    - Certified key identifier
 * @param  i_expir_date          - Certificate expiration date
 * @param  i_tracking_number     - Certificate request number or member identifier assigned by certificate authority
 * @param  i_subject_id          - Certificate subject identifier
 * @param  i_serial_number       - Certificate serial number assigned by certificate authority
 * @param  i_visa_service_id     - Identifies specific Visa service
 */
    procedure add_certificate (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_certified_key_id    in com_api_type_pkg.t_medium_id
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
    );

/*
 * Modify RSA certificate
 * @param  i_id                  - Certificate identifier
 * @param  io_seqnum             - Certificate sequence number
 * @param  i_certified_key_id    - Certified key identifier
 * @param  i_expir_date          - Certificate expiration date
 * @param  i_tracking_number     - Certificate request number or member identifier assigned by certificate authority
 * @param  i_subject_id          - Certificate subject identifier
 * @param  i_serial_number       - Certificate serial number assigned by certificate authority
 * @param  i_visa_service_id     - Identifies specific Visa service
 */
    procedure modify_certificate (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_certified_key_id    in com_api_type_pkg.t_medium_id
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
    );

/*
 * Remove RSA certificate
 * @param  i_id                  - Certificate identifier
 * @param  i_seqnum             - Certificate sequence number
 */
    procedure remove_certificate (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );
    
end;
/
