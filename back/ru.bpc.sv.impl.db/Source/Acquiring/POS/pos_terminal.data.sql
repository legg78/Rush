update pos_terminal set pos_batch_method = acq_api_terminal_pkg.get_pos_batch_method(id), partial_approval=acq_api_terminal_pkg.get_partial_approval(id), purchase_amount=acq_api_terminal_pkg.get_purchase_amount(id) 
/