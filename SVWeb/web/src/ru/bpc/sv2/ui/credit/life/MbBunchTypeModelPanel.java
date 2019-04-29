package ru.bpc.sv2.ui.credit.life;


import ru.bpc.sv2.accounts.BunchType;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;

public class MbBunchTypeModelPanel extends AbstractBean{
	private static final long serialVersionUID = 1L;


	private AccountsDao accountDao = new AccountsDao();

	private BunchType bunchType;

	public MbBunchTypeModelPanel(){
	}

	public void create(){
		bunchType = new BunchType();
		bunchType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void save(){
		if (isEditMode()) {
			bunchType = accountDao.editBunchType(userSessionId, bunchType);
		} else if (isNewMode()){
			bunchType = accountDao.addBunchType(userSessionId, bunchType);
		}
		curMode = VIEW_MODE;
	}

	public void cancel(){
		bunchType = null;
		curMode = VIEW_MODE;
	}


	public BunchType getBunchType() {
		return bunchType;
	}

	public void setBunchType(BunchType bunchType) {
		this.bunchType = bunchType;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}


}
