create or replace package cln_api_const_pkg is

ENTITY_TYPE_COLLECTION_CASE      constant com_api_type_pkg.t_dict_value := 'ENTTCNCS';

EVENT_TYPE_CASE_CREATED          constant com_api_type_pkg.t_dict_value := 'EVNT2501';
EVENT_TYPE_CASE_STATUS_CHANGED   constant com_api_type_pkg.t_dict_value := 'EVNT2502';
EVENT_TYPE_CASE_REASSIGNED       constant com_api_type_pkg.t_dict_value := 'EVNT2503';
EVENT_TYPE_CASE_MODIFIED         constant com_api_type_pkg.t_dict_value := 'EVNT2504';

COLLECTION_CASE_STATUS_NEW       constant com_api_type_pkg.t_dict_value := 'CLST0000';
COLLECTION_CASE_STATUS_OPENED    constant com_api_type_pkg.t_dict_value := 'CLST0001'; 
COLLECTION_CASE_STATUS_RESOLVD   constant com_api_type_pkg.t_dict_value := 'CLST0002';
COLLECTION_CASE_STATUS_CLOSED    constant com_api_type_pkg.t_dict_value := 'CLST0003';

COLL_ACTIVITY_CATEG_COLLECTOR    constant com_api_type_pkg.t_dict_value := 'CNACCRAT';
COLL_ACTIVITY_CATEG_CUST_RESP    constant com_api_type_pkg.t_dict_value := 'CNACCSRS';
COLL_ACTIVITY_CATEG_PLANNED      constant com_api_type_pkg.t_dict_value := 'CNACCPAT';
COLL_ACTIVITY_CATEG_SYSTEM       constant com_api_type_pkg.t_dict_value := 'CNACEVNT';

COLL_ACTIVITY_TYPE_COLD          constant com_api_type_pkg.t_dict_value := 'CRATCOLD';
COLL_ACTIVITY_TYPE_WARM          constant com_api_type_pkg.t_dict_value := 'CRATWARM';
COLL_ACTIVITY_TYPE_TECH          constant com_api_type_pkg.t_dict_value := 'CRATTLMS';
COLL_ACTIVITY_TYPE_LEGL          constant com_api_type_pkg.t_dict_value := 'CRATLEGL';
COLL_ACTIVITY_TYPE_MISC          constant com_api_type_pkg.t_dict_value := 'CRATCMNT';

COLL_OVERDUE_COND_ALL            constant com_api_type_pkg.t_dict_value := 'ODCT0000';
COLL_OVERDUE_COND_OVRD_ONLY      constant com_api_type_pkg.t_dict_value := 'ODCT0001';
COLL_OVERDUE_COND_WO_OVRD_ONLY   constant com_api_type_pkg.t_dict_value := 'ODCT0002';

end cln_api_const_pkg;
/
