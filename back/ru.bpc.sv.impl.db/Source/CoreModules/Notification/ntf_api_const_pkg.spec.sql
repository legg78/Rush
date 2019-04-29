create or replace package ntf_api_const_pkg is
/************************************************************
*  Constant for notification module <br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 29.12.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2012-04-17 13:19:08 +0400#$ <br />
*  Revision: $LastChangedRevision: 17731 $ <br />
*  Module: NTF_API_CONST_PKG <br />
*  @headcom
*************************************************************/

    NOTIFICATION_SCHEME_TYPE       constant com_api_type_pkg.t_dict_value := 'NTFS';
    CUSTOMER_NOTIFICATION_SCHEME   constant com_api_type_pkg.t_dict_value := 'NTFS0010';
    USER_NOTIFICATION_SCHEME       constant com_api_type_pkg.t_dict_value := 'NTFS0020';

    EVENT_TYPE_ISS_AUTH            constant com_api_type_pkg.t_dict_value := 'EVNT0191';
    EVENT_TYPE_ACQ_AUTH            constant com_api_type_pkg.t_dict_value := 'EVNT0291';
    EVENT_TYPE_LTY_CREATE_BONUS    constant com_api_type_pkg.t_dict_value := 'EVNT1103';
    EVENT_TYPE_LTY_SPEND_BONUS     constant com_api_type_pkg.t_dict_value := 'EVNT1104';
    EVNT_CHNG_NTF_ADDR             constant com_api_type_pkg.t_dict_value := 'EVNT2007';
    EVNT_CHNG_STTMT_DELIV_STATUS   constant com_api_type_pkg.t_dict_value := 'EVNT2008';
    EVNT_SEND_PROMOTION_MESSAGE    constant com_api_type_pkg.t_dict_value := 'EVNT2303';

    CYTP_SEND_PRELIMINARY_DUE_MESS constant com_api_type_pkg.t_dict_value := 'CYTP1014';
    CYTP_SEND_POSTERIOR_DUE_MESS   constant com_api_type_pkg.t_dict_value := 'CYTP1017';

    ENTITY_TYPE_NTF_MESSAGE        constant com_api_type_pkg.t_dict_value := 'ENTT0090';
    ENTITY_TYPE_NOTIFICATION       constant com_api_type_pkg.t_dict_value := 'ENTT0091';
    
    NOTIFICATION_CARD_SERVICE      constant com_api_type_pkg.t_short_id   := 10002000;
    NOTIFICATION_CUSTOMER_SERVICE  constant com_api_type_pkg.t_short_id   := 10000540;
    NOTIFICATION_ACQ_CUSTOMER_SRV  constant com_api_type_pkg.t_short_id   := 10002228;
    THREE_D_SECURE_CARD_SERVICE    constant com_api_type_pkg.t_short_id   := 10001717;

    CHANNEL_EMAIL                  constant com_api_type_pkg.t_tiny_id    := 1;
    CHANNEL_HARD_COPY              constant com_api_type_pkg.t_tiny_id    := 2;
    CHANNEL_SMS                    constant com_api_type_pkg.t_tiny_id    := 3;
    CHANNEL_GUI_NOTIFICATION       constant com_api_type_pkg.t_tiny_id    := 5;
    CHANNEL_PUSH                   constant com_api_type_pkg.t_tiny_id    := 6;
    
    NTF_SCHEME_EVENT               constant com_api_type_pkg.t_dict_value := 'NTES';
    STATUS_ALWAYS_SEND             constant com_api_type_pkg.t_dict_value := 'NTES0010';
    STATUS_SEND_SERVICE_ACTIVE     constant com_api_type_pkg.t_dict_value := 'NTES0020';
    STATUS_DO_NOT_SEND             constant com_api_type_pkg.t_dict_value := 'NTES0030';
    
    NOTIFICATION_SERVICE_USE_FEE   constant com_api_type_pkg.t_name       := 'NOTIFICATION_SERVICE_USE_FEE';
    NOTIFICATION_SCHEME            constant com_api_type_pkg.t_name       := 'NOTIFICATION_SCHEME';
    ACQ_SERVICE_NOTIFICATION_FEE   constant com_api_type_pkg.t_name       := 'ACQ_SERVICE_NOTIFICATION_FEE';
    ACQ_NOTIFICATION_SCHEME        constant com_api_type_pkg.t_name       := 'ACQ_NOTIFICATION_SCHEME';
    CUSTOMER_PROMOTIONAL_MESSAGE   constant com_api_type_pkg.t_name       := 'PROMOTIONAL_MESSAGE';

    MSG_STATUS_READY               constant com_api_type_pkg.t_dict_value := 'SGMSRDY';
    MSG_STATUS_SENT                constant com_api_type_pkg.t_dict_value := 'SGMSSENT';
    MSG_STATUS_DELIVERED           constant com_api_type_pkg.t_dict_value := 'SGMSDLVD';
    MSG_STATUS_ERROR               constant com_api_type_pkg.t_dict_value := 'SGMSCNSL';

    DEFAULT_DELIVERY_TIME          constant com_api_type_pkg.t_dict_value := '00-24';
    
    ACC_THRESHOLD_OVER_NTF_PROC    constant com_api_type_pkg.t_name       := 'EVT_PRC_NOTIFICATION_PKG.GEN_ACQ_MIN_AMOUNT_NOTIFS';

    TAG_USING_CUSTOM_EVENT         constant com_api_type_pkg.t_short_id   := 35091;

    FILE_TYPE_NOTIFICATIONS        constant com_api_type_pkg.t_dict_value := 'FLTPNTFC';
end;
/
