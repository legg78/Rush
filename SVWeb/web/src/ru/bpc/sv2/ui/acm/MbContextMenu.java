package ru.bpc.sv2.ui.acm;

import java.util.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ActionEvent;

import org.apache.log4j.Logger;

import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acm.AcmActionGroup;
import ru.bpc.sv2.acm.AcmActionValue;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbContextMenu")
public class MbContextMenu extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	
	private AccessManagementDao acmDao = new AccessManagementDao();
	
	private CommonDao commonDao = new CommonDao();
	
	private RolesDao rolesDao = new RolesDao();

	public static final String PANEL_PAGE = "panelPage";
	public static final String PANEL_NAME = "panelName";
	public static final String PANEL_INIT = "panelInit";
	public static final String APPLICATION = "createApplication";
	public static final String CREATE_OPERATION = "createOperation";
	public static final String RUN_REPORT = "runReport";
	public static final String VIEW_DETAILS = "viewDetails";
	public static final String VIEW_TRANSACTION_DETAILS = "viewTransactionDetails";
	public static final String VIEW_ACCOUNT_DETAILS = "viewAccountDetails";
	public static final String VIEW_CARD_DETAILS = "viewCardDetails";
	public static final String VIEW_MERCHANT_DETAILS = "viewMerchantDetails";
	public static final String VIEW_TERMINAL_DETAILS = "viewTerminalDetails";
	public static final String VIEW_PAYMENT_ORDER_DETAILS = "viewPaymentOrderDetails";
	public static final String VIEW_CONTRACT_DETAILS = "viewContractDetails";
	public static final String VIEW_CUSTOMER_DETAILS = "viewCustomerDetails";
	public static final String VIEW_PRODUCT_DETAILS = "viewProductDetails";
	public static final String VIEW_DEVICE_DETAILS = "viewDeviceDetails";
	public static final String VIEW_INSTITUTION_DETAILS = "viewInstitutionDetails";
	public static final String VIEW_AGENT_DETAILS = "viewAgentDetails";
	public static final String VIEW_RULE_SET_DETAILS = "viewRuleSetDetails";
	public static final String VIEW_USER_SET_DETAILS = "viewUserDetails";
	public static final String VIEW_APPLICATION_DETAILS = "viewApplicationDetails";
	public static final String VIEW_SESSION_DETAILS = "viewSessionDetails";
	public static final String VIEW_OPERATION_DETAILS = "viewOperationDetails";
	public static final String VIEW_CARDHOLDER_DETAILS = "viewCardholderDetails";
	
	private HashMap<String, HashMap<String, String>> actionParams;
	
	private String entityType;
	private String objectType;
	private AcmAction selectedCtxItem;
	
	protected String userLang;
	protected Long userSessionId = null;
	
	private Integer selectedItemId;
	private String beanContext;
	
	private HashMap<String, List<AcmAction>> menuItems;
	@Deprecated
	private HashMap<String, List<AcmAction>> includeItems;	// probably

	public MbContextMenu() {
		userLang = SessionWrapper.getField("language");
		String sessionId = SessionWrapper.getUserSessionIdStr();
		userSessionId = sessionId != null ? Long.parseLong(sessionId) : null;

		initActionParams();
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    private void initActionParams() {
		actionParams = new HashMap<String, HashMap<String, String>>();
		
		defineActionPanel("/pages/acquiring/applications/applicationModal.jspx", "appPanel", "", APPLICATION);
		defineActionPanel("/pages/accounts/adjusment_edit.jspx", "adjustmentModalPanel", "", CREATE_OPERATION);
		defineActionPanel("/pages/reports/reportModal.jspx", "reportRunPanel", "", RUN_REPORT);
		defineActionPanel("/pages/accounts/transactionDetails.jspx", "transactionDetails", "", VIEW_TRANSACTION_DETAILS);
		defineActionPanel("/pages/context/account_tabs.jspx", "accountDetailsModalPanel", "MbAccountsAllContextSearch", VIEW_ACCOUNT_DETAILS);
		defineActionPanel("/pages/context/card_tabs.jspx", "cardDetailsModalPanel", "MbCardsContextSearch", VIEW_CARD_DETAILS);
		defineActionPanel("/pages/context/merchant_tabs.jspx", "merchantDetailsModalPanel", "MbMerchantContext", VIEW_MERCHANT_DETAILS);
		defineActionPanel("/pages/context/terminal_tabs.jspx", "terminalDetailsModalPanel", "MbTerminalContext", VIEW_TERMINAL_DETAILS);
		defineActionPanel("/pages/context/paymentOrder_tabs.jspx", "paymentOrderDetailsModalPanel", "MbPmoPaymentOrdersContext", VIEW_PAYMENT_ORDER_DETAILS);
		defineActionPanel("/pages/products/products/details/contractDetailsForm.jspx", "contractDetailsModalPanel", "", VIEW_CONTRACT_DETAILS);
		defineActionPanel("/pages/context/customer_tabs.jspx", "customerDetailsModalPanel", "MbCustomerContext", VIEW_CUSTOMER_DETAILS);
		defineActionPanel("/pages/products/products/details/productDetailsForm.jspx", "productDetailsModalPanel", "", VIEW_PRODUCT_DETAILS);
		defineActionPanel("/pages/communication/deviceDetailsForm.jspx", "deviceDetailsModalPanel", "", VIEW_DEVICE_DETAILS);
		defineActionPanel("/pages/context/institution_tabs.jspx", "institutionDetailsModalPanel", "MbInstitutionContext", VIEW_INSTITUTION_DETAILS);
		defineActionPanel("/pages/context/agent_tabs.jspx", "agentDetailsModalPanel", "MbAgentContext", VIEW_AGENT_DETAILS);
		defineActionPanel("/pages/context/application_tabs.jspx", "applicationDetailsModalPanel", "MbApplicationsContextSearch", VIEW_APPLICATION_DETAILS);
		defineActionPanel("/pages/context/rule_set_tabs.jspx", "ruleSetDetailsModalPanel", "MbRuleSetsContext", VIEW_RULE_SET_DETAILS);
		defineActionPanel("/pages/context/user_tabs.jspx", "userDetailsModalPanel", "MbUsersContextSearch", VIEW_USER_SET_DETAILS);
		defineActionPanel("/pages/context/session_tabs.jspx", "sessionDetailsModalPanel", "MbProcessSessionsContextSearch", VIEW_SESSION_DETAILS);
		defineActionPanel("/pages/context/operation_tabs.jspx", "operationDetailsModalPanel", "MbOperationContext", VIEW_OPERATION_DETAILS);
		defineActionPanel("/pages/context/product_tabs.jspx", "productDetailsModalPanel", "MbProductContext", VIEW_PRODUCT_DETAILS);
		defineActionPanel("/pages/context/contract_tabs.jspx", "contractDetailsModalPanel", "MbContractContext", VIEW_CONTRACT_DETAILS);
		defineActionPanel("/pages/context/cardholder_tabs.jspx", "cardholderDetailsModalPanel", "MbCardholdersContextSearch", VIEW_CARDHOLDER_DETAILS);
		defineActionPanel("/pages/context/service_tabs.jspx", "serviceDetailsModalPanel", "MbServiceContext", VIEW_DETAILS);
	}
	
	public void defineActionPanel(String panelPage, String panelName, String panelInit, String paramName){
		HashMap<String, String> paramsMap = new HashMap<String, String>();
		paramsMap.put(PANEL_PAGE, panelPage);
		paramsMap.put(PANEL_NAME, panelName);
		paramsMap.put(PANEL_INIT, panelInit);
		actionParams.put(paramName, paramsMap);
	}
	
	public HashMap<String, HashMap<String, String>> getActionParams() {
		return actionParams;
	}

	public void setActionParams(HashMap<String, HashMap<String, String>> actionParams) {
		this.actionParams = actionParams;
	}

	/**
	 * 
	 */
	private void initMenuItems() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("noGroup");
		filters[1].setValue(1);

		SortElement[] sorters = new SortElement[2];
		sorters[0] = new SortElement("entityType", Direction.ASC);
		sorters[1] = new SortElement("objectType", Direction.ASC);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setSortElement(sorters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		try {
			AcmAction[] actions = acmDao.getAcmActionsWithParamsNoPriv(userSessionId, params);
			if (actions != null && actions.length > 0) {
				menuItems = new HashMap<String, List<AcmAction>>();
				includeItems = new HashMap<String, List<AcmAction>>();
				List<AcmAction> menuList = new ArrayList<AcmAction>();
				List<AcmAction> includeList = new ArrayList<AcmAction>();
				
				String lastKey = actions[0].getEntityType();
				for (AcmAction action: actions) {
					if (!lastKey.equals(action.getEntityType())) {
						menuItems.put(lastKey, menuList);
						includeItems.put(lastKey, includeList);
						menuList = new ArrayList<AcmAction>();
						includeList = new ArrayList<AcmAction>();
						lastKey = action.getEntityType();
					}
					menuList.add(action);
					if (action.isModalItem() || action.isRunnableItem()) {
						includeList.add(action);
					}
				}
				menuItems.put(lastKey, menuList);
				includeItems.put(lastKey, includeList);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			menuItems = null;
			includeItems = null;
		}

		filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		
		sorters = new SortElement[1];
		sorters[0] = new SortElement("entityType", Direction.ASC);
		params = new SelectionParams();
		params.setFilters(filters);
		params.setSortElement(sorters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		Filter[] actionFilters = new Filter[3];
		actionFilters[0] = filters[0];
		
		// now, take groups and then add actions that are inside these groups
		try {
			AcmActionGroup[] groups = acmDao.getAcmActionGroupsNoPriv(userSessionId, params);
			
			if (groups.length < 1) {
				return;
			}
			
			if (menuItems == null) {
				menuItems = new HashMap<String, List<AcmAction>>();
			}
			List<AcmAction> groupsList = new ArrayList<AcmAction>();
			String lastEntity = null;
			if (groups.length > 0) {
				lastEntity = groups[0].getEntityType();
				for (AcmActionGroup group : groups) {
					if (!lastEntity.equals(group.getEntityType())) {
						if (groupsList.size() > 0) {
							if (menuItems.get(lastEntity) != null) {
								groupsList.addAll(menuItems.get(lastEntity));
							}
							menuItems.put(lastEntity, groupsList);
							groupsList = new ArrayList<AcmAction>();
						}
						lastEntity = group.getEntityType();
					}

					actionFilters[1] = new Filter();
					actionFilters[1].setElement("groupId");
					actionFilters[1].setValue(group.getId());
					actionFilters[2] = new Filter();
					actionFilters[2].setElement("entityType");
					actionFilters[2].setValue(group.getEntityType());

					SelectionParams actionParams = new SelectionParams();
					actionParams.setFilters(actionFilters);
					actionParams.setRowIndexEnd(Integer.MAX_VALUE);

					AcmAction[] actions = acmDao.getAcmActionsWithParamsNoPriv(userSessionId, actionParams);
					if (actions.length == 0) continue;

					AcmAction action = new AcmAction();
					action.setLabel(group.getName());
					action.setGroup(true);
					action.setChildren(makeList(actions));
					groupsList.add(action);
				}
			}
			if (groupsList.size() > 0) {
				if (menuItems.get(lastEntity) != null) {
					groupsList.addAll(menuItems.get(lastEntity));
				}
				menuItems.put(lastEntity, groupsList);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	private void initMenuItems2() {
		menuItems = new HashMap<String, List<AcmAction>>();
		includeItems = new HashMap<String, List<AcmAction>>();
		
		try {
			addGroupedActions();
			addIndependentActions();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			menuItems = new HashMap<String, List<AcmAction>>(0);
			includeItems = new HashMap<String, List<AcmAction>>(0);
		}
	}

	/**
	 * <p>
	 * Adds action groups to menu along with their children actions. Intended to
	 * be used first (before adding ordinary actions) in menu initialization.
	 * </p>
	 * 
	 * @throws Exception
	 */
	private void addGroupedActions() throws Exception {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		
		SortElement[] sorters = new SortElement[1];
		sorters[0] = new SortElement("entityType", Direction.ASC);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setSortElement(sorters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		AcmActionGroup[] groups = acmDao.getAcmActionGroupsNoPriv(userSessionId, params);
		
		if (groups.length < 1) {
			return;
		}

		// filters for actions
		Filter[] actionFilters = new Filter[3];
		actionFilters[0] = filters[0];

		// sort actions by object type
		sorters = new SortElement[1];
		sorters[0] = new SortElement("objectType", Direction.ASC);
		
		SelectionParams actionParams = new SelectionParams();
		actionParams.setSortElement(sorters);
		actionParams.setRowIndexEnd(Integer.MAX_VALUE);

		for (AcmActionGroup group: groups) {
			actionFilters[1] = new Filter();
			actionFilters[1].setElement("groupId");
			actionFilters[1].setValue(group.getId());
			actionFilters[2] = new Filter();
			actionFilters[2].setElement("entityType");
			actionFilters[2].setValue(group.getEntityType());
			
			actionParams.setFilters(actionFilters);
			
			AcmAction[] actions = acmDao.getAcmActionsWithParamsNoPriv(userSessionId, actionParams);
			if (actions.length == 0) continue;
			
			formGroupsAndAddToMenu(group, actions);
		}
	}

	/**
	 * <p>
	 * Forms groups and adds them to menu. Groups are formed according to
	 * <code>entityKey</code> field of each item of <code>actions</code> array.
	 * So, inspite of only one group is passed to the method there can be
	 * multiple groups formed.
	 * </p>
	 * 
	 * @param group
	 * @param actions
	 */
	private void formGroupsAndAddToMenu(AcmActionGroup group, AcmAction[] actions) {
		List<AcmAction> itemsWithoutObjectType = new ArrayList<AcmAction>();
		List<AcmAction> itemsWithObjectType = new ArrayList<AcmAction>();
		List<AcmAction> includeList = new ArrayList<AcmAction>();

		Map<String, List<AcmAction>> tempMenuItems = new HashMap<String, List<AcmAction>>();
		
		String lastKey = actions[0].getEntityKey();
		
		String lastObjectType = actions[0].getObjectType();
		for (AcmAction action: actions) {
			if (!lastKey.equals(action.getEntityKey())) {
				// form new group: it should be of type AcmAction to be consistent with other menu items
				AcmAction newGroup = new AcmAction();
				newGroup.setLabel(group.getName());
				newGroup.setGroup(true);
				if (lastObjectType != null) {
					newGroup.setChildren(itemsWithObjectType);
				} else {
					newGroup.setChildren(itemsWithoutObjectType);
				}

				// we should add this group as List as later we can add to menu more elements with same key 
				List<AcmAction> newList = new ArrayList<AcmAction>();
				newList.add(newGroup);
				
				// save it in temporary map to add common actions to it if there are any
				tempMenuItems.put(lastKey, newList);

				itemsWithObjectType = new ArrayList<AcmAction>();
				lastKey = action.getEntityKey();
				lastObjectType = action.getObjectType();
			}
			
			if (lastObjectType != null) {
				itemsWithObjectType.add(action);
			} else {
				itemsWithoutObjectType.add(action);
			}
			if (action.isModalItem() || action.isRunnableItem()) {
				includeList.add(action);
			}
		}

		// add last group
		if (itemsWithObjectType.size() > 0) {
			AcmAction newGroup = new AcmAction();
			newGroup.setLabel(group.getName());
			newGroup.setGroup(true);
			newGroup.setChildren(itemsWithObjectType);

			List<AcmAction> newList = new ArrayList<AcmAction>();
			newList.add(newGroup);
			tempMenuItems.put(lastKey, newList);
		}

		// add common actions
		if (itemsWithoutObjectType.size() > 0) {
			// add common actions to all groups with same entity type and where object type is not empty
			
			// FIX: add them later in getCurrentMenuItems() 
//			for (String key : tempMenuItems.keySet()) {
//				if (tempMenuItems.get(key).get(0).getObjectType() != null) {
//					tempMenuItems.get(key).get(0).getChildren().addAll(0, itemsWithoutObjectType);
//				}
//			}
			
			// if lastObjectType is empty than we still don't have group with actions without object type
			// create it
			if (lastObjectType == null) {
				AcmAction newGroup = new AcmAction();
				newGroup.setLabel(group.getName());
				newGroup.setGroup(true);
				newGroup.setChildren(itemsWithoutObjectType);

				List<AcmAction> newList = new ArrayList<AcmAction>();
				newList.add(newGroup);
				tempMenuItems.put(lastKey, newList);
			}
		}
		
		// add completely formed groups to menu
		menuItems.putAll(tempMenuItems);

		includeItems.put(lastKey, includeList);	// TODO: either delete it or fill the same way as menuItems
	}


	/**
	 * <p>Adds actions to menu that aren't included in any group.</p>
	 * @throws Exception
	 */
	private void addIndependentActions() throws Exception {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("noGroup");
		filters[1].setValue(1);

		SortElement[] sorters = new SortElement[2];
		sorters[0] = new SortElement("entityType", Direction.ASC);
		sorters[1] = new SortElement("objectType", Direction.ASC);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setSortElement(sorters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		AcmAction[] actions = acmDao.getAcmActionsWithParamsNoPriv(userSessionId, params);
		if (actions != null && actions.length > 0) {

			List<AcmAction> emptyObjectItems = new ArrayList<AcmAction>();
			List<AcmAction> filledObjectItems = new ArrayList<AcmAction>();
			List<AcmAction> includeList = new ArrayList<AcmAction>();
	
			Map<String, List<AcmAction>> tempMenuItems = new HashMap<String, List<AcmAction>>();
			
			String lastKey = actions[0].getEntityKey();
			
			String lastEntityType = actions[0].getEntityType();
			String lastObjectType = actions[0].getObjectType();
			for (AcmAction action: actions) {
				if (!lastKey.equals(action.getEntityKey())) {
					// save it in temporary map to add common actions to it when entity type changes
					if (filledObjectItems.size() > 0) {
						tempMenuItems.put(lastKey, filledObjectItems);
					}
	
					if (!lastEntityType.equals(action.getEntityType())) {
						// this one supposes a major change
						
						// add common actions to all groups with same entity type but different object type
						if (emptyObjectItems.size() > 0) {
							// FIX: we'll add them on getting in getCurrentMenuItems()
//							for (String key : tempMenuItems.keySet()) {
//								tempMenuItems.get(key).addAll(0, emptyObjectItems);
//							}
							
							// there can be actions that don't have object type, so we must create 
							// mapping for them too 
							tempMenuItems.put(lastEntityType, emptyObjectItems);
						}
						
						// add actions to menu
						for (String key : tempMenuItems.keySet()) {
							if (menuItems.get(key) != null) {
								menuItems.get(key).addAll(tempMenuItems.get(key));
							} else {
								menuItems.put(key, tempMenuItems.get(key));
							}
						}
						includeItems.put(lastKey, includeList);
						
						tempMenuItems = new HashMap<String, List<AcmAction>>();
						emptyObjectItems = new ArrayList<AcmAction>();
						includeList = new ArrayList<AcmAction>();
						lastEntityType = action.getEntityType();
					}
					filledObjectItems = new ArrayList<AcmAction>();
					lastKey = action.getEntityKey();
					lastObjectType = action.getObjectType();
				}
				
				if (lastObjectType != null) {
					filledObjectItems.add(action);
				} else {
					emptyObjectItems.add(action);
				}
				if (action.isModalItem() || action.isRunnableItem()) {
					includeList.add(action);
				}
			}
	
			// add last actions
			if (filledObjectItems.size() > 0) {
				tempMenuItems.put(lastKey, filledObjectItems);
			}
			
			if (emptyObjectItems.size() > 0) {
				// add common actions to all groups with same entity type but different object type
				
				// FIX: we'll add them on getting in getCurrentMenuItems()
//				for (String key : tempMenuItems.keySet()) {
//					tempMenuItems.get(key).addAll(0, emptyObjectItems);
//				}
					
				// there can be actions that don't have object type, so we must create 
				// mapping for them too 
				tempMenuItems.put(lastEntityType, emptyObjectItems);
			}

			if (tempMenuItems.size() > 0) {
				// add actions to menu
				for (String key : tempMenuItems.keySet()) {
					if (menuItems.get(key) != null) {
						menuItems.get(key).addAll(tempMenuItems.get(key));
					} else {
						menuItems.put(key, tempMenuItems.get(key));
					}
				}
			}
			includeItems.put(lastKey, includeList);	// TODO: either delete it or fill the same way as menuItems
		}
	}


	protected int addNodes(int startIndex, List<AcmActionGroup> branches, AcmActionGroup[] items) {
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<AcmActionGroup>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
		}
		return i - 1;
	}

	public HashMap<String, List<AcmAction>> getMenuItems() {
		if (menuItems == null || menuItems.size() == 0) {
			//initMenuItems2();
			initMenuItems();
		}
		return menuItems;
	}

	public HashMap<String, List<AcmAction>> getIncludeItems() {
		if (includeItems == null || includeItems.size() == 0) {
			//initMenuItems2();
			initMenuItems();
		}
		return includeItems;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

//	ContextMenu popupMenu;
//	String beanName = "MbEntriesForOperation";
//	String subviewName = "operEntriesSubview";
//	public ContextMenu getPopupMenu() {
//		 popupMenu = new ContextMenu();
//		 initMenuItems2();
//		if (menuItems.size() == 0
//				|| menuItems.get(entityType + (objectType == null ? "" : objectType)) == null) {
//			 return popupMenu;
//		 }
//		 
//		 List<HtmlMenuItem> components = new ArrayList<HtmlMenuItem>();
//		 
//		 popupMenu.setAttached(false);
//		 popupMenu.setSubmitMode("ajax");
//		 popupMenu.setId("operEntriesCtxMenu");
//		 popupMenu.setDisableDefaultMenu(true);
//		 popupMenu.setSelectItemClass("selected-menu-item");
//		 for (AcmAction action : menuItems.get(entityType + (objectType == null ? "" : objectType))) {
//			HtmlMenuItem item = new HtmlMenuItem();
//			item.setValue(action.getLabel());
//			MethodExpression expression = null;
//			if (action.isActionItem()) {
//				expression = FacesContext.getCurrentInstance().getApplication()
//						.getExpressionFactory().createMethodExpression(
//								FacesContext.getCurrentInstance().getELContext(),
//								"#{" + beanName + ".ctxPageForward}", null, new Class<?>[0]);
//			} else if (action.isModalItem()) {
//				expression = FacesContext.getCurrentInstance().getApplication()
//						.getExpressionFactory().createMethodExpression(
//								FacesContext.getCurrentInstance().getELContext(),
//								"#{" + beanName + ".initCtxParams}", null, new Class<?>[0]);
//				item.setOncomplete("Richfaces.showModalPanel('" + subviewName + ":" 
//						+ actionParams.get(action.getAction()).get(PANEL_NAME) + "');");
//			} else if (action.isModalItem()) {
//				expression = FacesContext.getCurrentInstance().getApplication()
//						.getExpressionFactory().createMethodExpression(
//								FacesContext.getCurrentInstance().getELContext(),
//								"#{" + beanName + ".initCtxParams}", null, new Class<?>[0]);
//				item.setOncomplete(subviewName + "_callAction();");
//			}
//			item.setActionExpression(expression);
//			item.setData(action);
//			item.setSubmitMode("ajax");
//			components.add(item);
//		 }
//		 popupMenu.getChildren().clear();
//		 popupMenu.getChildren().addAll(components);
//		 return popupMenu;
//	}
//
//	public void setPopupMenu(ContextMenu popupMenu) {
//		this.popupMenu = popupMenu;
//	}

	public void onItemClick(ActionEvent event) {
		Object obj = event.getSource();
		if (obj instanceof org.richfaces.component.html.HtmlMenuItem) {
			org.richfaces.component.html.HtmlMenuItem item = (org.richfaces.component.html.HtmlMenuItem) obj;
			logger.trace(item.getValue());
		}
	}

	/**
	 * <p>
	 * Puts all action values which were set for selected context item (i.e. 
	 * action) into session. Functional values are calculated using 
	 * <code>entityType</code> and <code>objectId</code>.
	 * </p>   
	 */
	public void initCtxParams(String entityType, Long objectId) {
		initCtxParams(entityType, objectId, false);
	}
	
	/**
	 * <p>
	 * Puts all action values which were set for selected context item (i.e. 
	 * action) into session. Functional values are calculated using 
	 * <code>entityType</code> and <code>objectId</code>.
	 * </p>
	 * @param entityType - object entity type
	 * @param objectId - object ID
	 * @param packParams - if <code>true</code> all parameters will be stored
	 * in session as one <code>java.util.Map</code> named "CTX_MENU_PARAMS".  
	 */
	public void initCtxParams(String entityType, Long objectId, boolean packParams) {
		Map<String, Object> ctxMenuParams = null;
		if (packParams) {
			ctxMenuParams = new HashMap<String, Object>(selectedCtxItem.getActionValues().size());
			ctxMenuParams.put("I_ENTITY_TYPE", entityType);
		}
		for (AcmActionValue value: selectedCtxItem.getActionValues()) {
			if (value.getParamFunction() != null) {
				if (ctxMenuParams != null) {
					ctxMenuParams.put(value.getParamSystemName(), getFunctionValue(value
							.getParamFunction(), entityType, objectId, value.getDataType()));
				} else {
					FacesUtils.setSessionMapValue(value.getParamSystemName(), getFunctionValue(value
							.getParamFunction(), entityType, objectId, value.getDataType()));
				}
			} else {
				if (ctxMenuParams != null) {
					if (DataTypes.CHAR.equals(value.getDataType()) && value.getValueV() != null) {
						ctxMenuParams.put(value.getParamSystemName(), value.getValueV());
					} else if (DataTypes.NUMBER.equals(value.getDataType()) && value.getValueN() != null) {
						ctxMenuParams.put(value.getParamSystemName(), value.getValueN());
					} else if (DataTypes.DATE.equals(value.getDataType()) && value.getValueD() != null) {
						ctxMenuParams.put(value.getParamSystemName(), value.getValueD());
					}
				} else {
					if (DataTypes.CHAR.equals(value.getDataType()) && value.getValueV() != null) {
						FacesUtils.setSessionMapValue(value.getParamSystemName(), value.getValueV());
					} else if (DataTypes.NUMBER.equals(value.getDataType()) && value.getValueN() != null) {
						FacesUtils.setSessionMapValue(value.getParamSystemName(), value.getValueN());
					} else if (DataTypes.DATE.equals(value.getDataType()) && value.getValueD() != null) {
						FacesUtils.setSessionMapValue(value.getParamSystemName(), value.getValueD());
					}
				}
			}
		}
		
		if (packParams) {
			FacesUtils.setSessionMapValue("CTX_MENU_PARAMS", ctxMenuParams);
		}
	}
	
	public AcmAction getSelectedCtxItem() {
		return selectedCtxItem;
	}

	public void setSelectedCtxItem(AcmAction selectedCtxItem) {
		this.selectedCtxItem = selectedCtxItem;
	}

	public Object getFunctionValue(String functionName, String entityType, Long objectId, String dataType) {
		try {
			return commonDao.getFunctionValue(userSessionId, functionName, entityType, objectId, dataType);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return null;
	}
	
	public ArrayList<AcmAction> makeList(AcmAction[] actions) {
		ArrayList<AcmAction> result = new ArrayList<AcmAction>(actions.length);
		Collections.addAll(result, actions);
		return result;
	}
	
	public AcmAction getDefaultAction(Integer instId) {
		Filter[] filters;
		if (objectType != null)
			filters = new Filter[6];
		else
			filters = new Filter[5];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("entityType");
		filters[1].setValue(entityType);
		filters[2] = new Filter();
		filters[2].setElement("instId");
		filters[2].setValue(instId);
		filters[3] = new Filter();
		filters[3].setElement("default");
		filters[3].setValue(true);
		filters[4] = new Filter();
		filters[4].setElement("callMode");
		filters[4].setValue(AcmAction.ACTION_ITEM);
		if (objectType != null){
			filters[5] = new Filter();
			filters[5].setElement("objectType");
			filters[5].setValue(objectType);
		}
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AcmAction[] actions = acmDao.getAcmActionsWithParams(userSessionId, params);
			if (actions.length > 0) {
				if (actions[0].getPrivId() != null) {
					UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
					Privilege privilege = rolesDao.getPrivilegeById(userSessionId, actions[0].getPrivId(), userLang);
					if (usession.getInRole().get(privilege.getName())) {
						return actions[0];
					} else {
						FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm",
								"INSUFFICIENT_PRIVILEGES", actions[0].getPrivName()));
						return null;
					}
				} else {
					return actions[0];
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}
	
	public String getPanelViewId() {
		return "/pages/context/contextModal.jspx";
	}
	
	public String getDetalsViewId() {
		try {
			return actionParams.get(selectedCtxItem.getAction()).get(PANEL_PAGE);
		} catch (NullPointerException e) {
			return SystemConstants.EMPTY_PAGE;
		}
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}
	
	public synchronized List<AcmAction> getCurrentMenuItems() {
		if (menuItems == null || menuItems.size() == 0) {
			initMenuItems2();
		}
		if (entityType == null) {
			return null;
		}
		//return menuItems.get(entityType + (objectType == null ? "" : objectType));

		// combine menu items with and without object type here to get menu for all objects
		// even for those which demand object type but don't have items with their object 
		// type and do have some common items for their entity type.
		List<AcmAction> actions = null;
		if (menuItems.containsKey(entityType)) {
			actions = new ArrayList<AcmAction>(menuItems.get(entityType));
		}
		
		if (objectType != null && menuItems.containsKey(entityType + objectType)) {
			if (actions == null || actions.isEmpty()) {
				actions = menuItems.get(entityType + objectType);
			} else {
				actions.addAll(menuItems.get(entityType + objectType));
			}
		}
		return actions;
	}

	public List<AcmAction> getCurrentIncludeItems() {
		if (includeItems == null || includeItems.size() == 0) {
			initMenuItems2();
		}
		if (entityType == null) {
			return null;
		}
		return includeItems.get(entityType + (objectType == null ? "" : objectType));
	}

	public Integer getSelectedItemId() {
		return selectedItemId;
	}

	public void setSelectedItemId(Integer selectedItemId) {
		this.selectedItemId = selectedItemId;
		if (selectedItemId != null) {
			for (AcmAction action: getCurrentMenuItems()) {
				if (action.getId().equals(selectedItemId)) {
					selectedCtxItem = action;
					return;
				}
			}
		}
	}

	public String getBeanContext() {
		return beanContext;
	}

	public void setBeanContext(String beanContext) {
		this.beanContext = beanContext.substring(beanContext.lastIndexOf(".")+1);
	}
	
}
