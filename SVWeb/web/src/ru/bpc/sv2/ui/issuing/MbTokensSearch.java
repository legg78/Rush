package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Token;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbTokensSearch")
public class MbTokensSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("NOTES");

    private Token filter;
    private Token activeToken;
    private String tabName;
    private List<SelectItem> statuses;

    private IssuingDao issuingDao = new IssuingDao();

    private final DaoDataModel<Token> tokensSource;
    private final TableRowSelection<Token> itemSelection;

    public MbTokensSearch() {
        tokensSource = new DaoDataModel<Token>() {
            @Override
            protected Token[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return issuingDao.getTokens(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        logger.error("", e);
                        FacesUtils.addMessageError(e);
                    }
                }
                return new Token[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return issuingDao.getTokensCount(userSessionId, params);
                    } catch (Exception e) {
                        logger.error("", e);
                        FacesUtils.addMessageError(e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<Token>(null, tokensSource);
    }

    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();
        if (filter.getId() != null) {
            filters.add(new Filter("id", filter.getId() + "%"));
        }
        if (filter.getCardId() != null) {
            filters.add(new Filter("cardId", filter.getCardId()));
        }
        if (filter.getCardInstanceId() != null) {
            filters.add(new Filter("cardInstanceId", filter.getCardInstanceId()));
        }
        if (filter.getExpirationDate() != null) {
            filters.add(new Filter("expirDate", filter.getExpirationDate()));
        }
        if (filter.getStatus() != null && !filter.getStatus().trim().isEmpty()) {
            filters.add(new Filter("status", filter.getStatus().trim()));
        }
        if (filter.getWalletProvider() != null && !filter.getWalletProvider().trim().isEmpty()) {
            filters.add(new Filter("walletProvider", filter.getWalletProvider().trim()));
        }
    }

    public Token getFilter() {
        if (filter == null) {
            filter = new Token();
        }
        return filter;
    }
    public void setFilter(Token filter) {
        this.filter = filter;
    }

    public Token getActiveToken() {
        return activeToken;
    }
    public void setActiveToken(Token activeToken) {
        this.activeToken = activeToken;
    }

    public SimpleSelection getItemSelection() {
        if (activeToken == null && tokensSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeToken != null && tokensSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeToken.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeToken = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeToken = itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        tokensSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeToken = (Token)tokensSource.getRowData();
        selection.addKey(activeToken.getModelId());
        itemSelection.setWrappedSelection(selection);
    }
    public void clearState() {
        itemSelection.clearSelection();
        activeToken = null;
        tokensSource.flushCache();
        curLang = userLang;
    }
    public void search() {
        clearState();
        searching = true;
    }

    public List<SelectItem> getStatuses() {
        if (statuses == null) {
            statuses = getDictUtils().getLov(LovConstants.STATUS);
            for (Iterator<SelectItem> iterator = statuses.iterator(); iterator.hasNext(); ) {
                SelectItem status = iterator.next();
                if (!status.getValue().toString().substring(0, 4).equals(DictNames.TOKEN_STATUS)) {
                    iterator.remove();
                }
            }
        }
        return statuses;
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public DaoDataModel<Token> getTokens() {
        return tokensSource;
    }

    @Override
    public void clearFilter() {

    }
}
