create or replace package sec_api_type_pkg is
/**********************************************************
 * Security types
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.06.2010
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_type_pkg
 * @headcom
 **********************************************************/    

    subtype t_key_value           is varchar2(79);
    subtype t_key_prefix          is varchar2(50);
    subtype t_check_value         is varchar2(16);
    subtype t_kcv_value           is varchar2(16);
    subtype t_tracking_number     is number(6);
    subtype t_subject_id          is varchar2(10);
    subtype t_serial_number       is varchar2(6);

    type            t_des_key_rec is record (
        id                  com_api_type_pkg.t_medium_id
        , key_type          com_api_type_pkg.t_dict_value
        , key_index         com_api_type_pkg.t_tiny_id
        , key_length        com_api_type_pkg.t_tiny_id
        , key_value         t_key_value
        , key_prefix        t_key_prefix
        , check_value       t_check_value
        , lmk_id             com_api_type_pkg.t_tiny_id
    );
    type            t_des_key_tab is table of t_des_key_rec index by binary_integer;

    type            t_authority_rec is record (
        id                   com_api_type_pkg.t_tiny_id
        , seqnum             com_api_type_pkg.t_tiny_id
        , authority_type     com_api_type_pkg.t_dict_value
        , rid                t_subject_id
    );
    type            t_authority_tab is table of t_authority_rec index by binary_integer;
    
    type            t_rsa_key_rec is record (
        id                   com_api_type_pkg.t_medium_id
        , seqnum             com_api_type_pkg.t_seqnum
        , object_id          com_api_type_pkg.t_long_id
        , entity_type        com_api_type_pkg.t_dict_value
        , lmk_id             com_api_type_pkg.t_tiny_id
        , key_type           com_api_type_pkg.t_dict_value
        , key_index          com_api_type_pkg.t_tiny_id
        , expir_date         date
        , sign_algorithm     com_api_type_pkg.t_dict_value
        , modulus_length     com_api_type_pkg.t_tiny_id
        , exponent           com_api_type_pkg.t_exponent
        , public_key         com_api_type_pkg.t_key
        , private_key        com_api_type_pkg.t_key
        , public_key_mac     com_api_type_pkg.t_pin_block
        , certificate        com_api_type_pkg.t_key
        , reminder           com_api_type_pkg.t_key
        , hash               com_api_type_pkg.t_key
        , subject_id         t_subject_id
        , serial_number      t_serial_number
        , visa_service_id    com_api_type_pkg.t_dict_value
    );
    type            t_rsa_key_tab is table of t_rsa_key_rec index by binary_integer;

    type            t_rsa_certificate_rec is record (
        id                   com_api_type_pkg.t_medium_id
        , state              com_api_type_pkg.t_dict_value
        , authority_id       com_api_type_pkg.t_tiny_id
        , authority_type     com_api_type_pkg.t_dict_value
        , certified_key_id   com_api_type_pkg.t_medium_id
        , authority_key_id   com_api_type_pkg.t_medium_id
        , certificate        com_api_type_pkg.t_key
        , reminder           com_api_type_pkg.t_key
        , hash               com_api_type_pkg.t_key
        , expir_date         date
        , tracking_number    t_tracking_number
        , subject_id         t_subject_id
        , serial_number      t_serial_number
        , visa_service_id    com_api_type_pkg.t_dict_value
    );
    type            t_rsa_certificate_tab is table of t_rsa_certificate_rec index by binary_integer;
    
end;
/
