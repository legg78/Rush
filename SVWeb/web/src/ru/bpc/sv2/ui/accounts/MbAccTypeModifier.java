package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.AccTypeModifier;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAccTypeModifier")
public class MbAccTypeModifier extends AbstractBean {
	
	private List<AccTypeModifier> storedAccTypeMod;
	
	private Map<Integer,AccTypeModifier> addedAccTypeMod;
	
	private List<Integer> removedAccTypeMod;
	
	private AccTypeModifier _activeModifier;

	private final DaoDataModel<AccTypeModifier> _debitModifiersSource;

	private final TableRowSelection<AccTypeModifier> _itemSelection;
	
	AccTypeModifier newAccTypeModifier;
	
	private ArrayList<SelectItem>  modifiers = null;
	
	private int fakeId;

	public MbAccTypeModifier() {
		
		fakeId = -1;
		addedAccTypeMod = new HashMap<Integer,AccTypeModifier>();
		removedAccTypeMod = new ArrayList<Integer>();
		storedAccTypeMod = new ArrayList<AccTypeModifier>();
		
		_debitModifiersSource = new DaoDataModel<AccTypeModifier>() {

			private static final long serialVersionUID = 1L;
			 
			@Override
			protected AccTypeModifier[] loadDaoData(SelectionParams params) {
				return (AccTypeModifier[]) storedAccTypeMod.toArray(new AccTypeModifier[storedAccTypeMod.size()]);
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				return storedAccTypeMod.size();
			}
		};

		_itemSelection = new TableRowSelection<AccTypeModifier>(null, _debitModifiersSource);
	}

	public DaoDataModel<AccTypeModifier> getDebitModifiers() {
		return _debitModifiersSource;
	}

	public AccTypeModifier getActiveModifier() {
		return _activeModifier;
	}

	public void setActiveModifier(AccTypeModifier activeModifier) {
		_activeModifier = activeModifier;
	}

	public SimpleSelection getItemSelection() {
		if (_activeModifier == null && _debitModifiersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeModifier != null && _debitModifiersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeModifier.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeModifier = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeModifier = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_debitModifiersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeModifier = (AccTypeModifier) _debitModifiersSource.getRowData();
		selection.addKey(_activeModifier.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void add() {
		newAccTypeModifier = new AccTypeModifier();
		newAccTypeModifier.setId(fakeId--);
	}

	public void save() {
		String modifierDesc = getDictUtils().getLovMap(LovConstants.MODIFIER_LIST).get(String.valueOf(newAccTypeModifier.getModId()));
		newAccTypeModifier.setModDesc(modifierDesc);
		storedAccTypeMod.add(newAccTypeModifier);
		addedAccTypeMod.put(newAccTypeModifier.getId(),newAccTypeModifier);
		_itemSelection.addNewObjectToList(newAccTypeModifier);
		curMode = VIEW_MODE;
		_activeModifier = newAccTypeModifier;
	}

	public void delete() {
		int index = 0;
		for (int i=0; i<storedAccTypeMod.size(); i++){
			if(storedAccTypeMod.get(i).getId().equals(_activeModifier.getId())){
				index = i;
			}
		}
		if(_activeModifier.getId()>0){
			removedAccTypeMod.add(_activeModifier.getId());
		}else{
			addedAccTypeMod.remove(_activeModifier.getId());
		}
		storedAccTypeMod.remove(index);
		curMode = VIEW_MODE;
		_activeModifier = _itemSelection
				.removeObjectFromList(_activeModifier);
		
	}

	public void close() {

	}

	public void clearBean() {

	}
	
	public AccTypeModifier getNewAccTypeModifier() {
		return newAccTypeModifier;
	}

	public void addAccTypeMods(List<AccTypeModifier> accTypeMods){
		storedAccTypeMod.addAll(accTypeMods);
	}
	
	public Map<Integer,AccTypeModifier> getAddedAccTypeMod() {
		return addedAccTypeMod;
	}

	public List<Integer> getRemovedAccTypeMod() {
		return removedAccTypeMod;
	}

	public List<AccTypeModifier> getStoredAccTypeMod() {
		return storedAccTypeMod;
	}

	public ArrayList<SelectItem> getModifiers(){
		if (modifiers == null || modifiers.isEmpty()) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_ENTRY_TEMPL);
			modifiers = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		}
		return modifiers;
	}

	@Override
	public void clearFilter() {
		storedAccTypeMod.clear();
		removedAccTypeMod.clear();
		addedAccTypeMod.clear();
		_itemSelection.clearSelection();
		_activeModifier = null;
		_debitModifiersSource.flushCache();
	}
}
