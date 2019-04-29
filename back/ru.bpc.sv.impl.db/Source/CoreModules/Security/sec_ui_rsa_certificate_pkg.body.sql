create or replace package body sec_ui_rsa_certificate_pkg is
/************************************************************
 * User interface for RSA certificates <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_rsa_certificate_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_certificate (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_certified_key_id    in com_api_type_pkg.t_medium_id
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := sec_rsa_certificate_seq.nextval;
        o_seqnum := 1;

        insert into sec_rsa_certificate_vw (
            id
            , seqnum
            , certified_key_id
            , authority_key_id
            , certificate
            , reminder
            , expir_date
            , tracking_number
            , subject_id
            , serial_number
            , visa_service_id
        ) values (
            o_id
            , o_seqnum
            , i_certified_key_id
            , null
            , null
            , null
            , i_expir_date
            , i_tracking_number
            , i_subject_id
            , i_serial_number
            , i_visa_service_id
        );

    end;

    procedure modify_certificate (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_certified_key_id    in com_api_type_pkg.t_medium_id
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            sec_rsa_certificate_vw
        set
            seqnum = io_seqnum
            , certified_key_id = i_certified_key_id
            , expir_date = i_expir_date
            , tracking_number = i_tracking_number
            , subject_id = i_subject_id
            , serial_number = i_serial_number
            , visa_service_id = i_visa_service_id
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

    end;

    procedure remove_certificate (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            sec_rsa_certificate_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            sec_rsa_certificate_vw
        where
            id = i_id;
    end;

end;
/
