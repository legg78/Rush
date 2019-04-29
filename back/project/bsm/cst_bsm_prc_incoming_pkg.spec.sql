create or replace package cst_bsm_prc_incoming_pkg is


-- Import information of priority product details in CSV format
procedure process_priority_prod_details;

-- Import information of priority account details in CSV format
procedure process_priority_acc_details;

end cst_bsm_prc_incoming_pkg;
/
