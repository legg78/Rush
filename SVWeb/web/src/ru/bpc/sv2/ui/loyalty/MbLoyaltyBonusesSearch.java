package ru.bpc.sv2.ui.loyalty;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.LoyaltyDao;
import ru.bpc.sv2.loyalty.LoyaltyBonus;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbLoyaltyBonusesSearch")
public class MbLoyaltyBonusesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("LOYALTY");

	private LoyaltyDao loyaltyDao = new LoyaltyDao();

	private LoyaltyBonus filter;

	private final DaoDataModel<LoyaltyBonus> loyaltyBonusesSource;
	
	private static String COMPONENT_ID = "loyaltyBonusesTable";
	private String tabName;
	private String parentSectionId;

	public MbLoyaltyBonusesSearch() {
		filter = new LoyaltyBonus();
		
		loyaltyBonusesSource = new DaoDataModel<LoyaltyBonus>() {
			@Override
			protected LoyaltyBonus[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new LoyaltyBonus[0];
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return loyaltyDao.getLoyaltyBonuses(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new LoyaltyBonus[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return loyaltyDao.getLoyaltyBonusesCount(userSessionId,
							params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

	}

	public void search() {
		clearState();
		searching = true;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter;

		if (filter.getAccountId() != null){
			paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setValue(filter.getAccountId().toString());
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}

	public void setAccountId(long accountId) {
		filter.setAccountId(accountId);
	}

	public DaoDataModel<LoyaltyBonus> getLoyaltyBonuses() {
		return loyaltyBonusesSource;
	}

	public void clearState() {
		loyaltyBonusesSource.flushCache();
	}

	public LoyaltyBonus getFilter(){
		if (filter == null){
			filter = new LoyaltyBonus();
		}
		return filter;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
