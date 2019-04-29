package ru.bpc.sv2.ui.scenario;

import java.util.ArrayList;
import java.util.HashMap;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.scenario.AuthParam;
import ru.bpc.sv2.scenario.AuthState;
import ru.bpc.sv2.scenario.Scenario;
import ru.bpc.sv2.ui.utils.FacesUtils;

import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbDiagram")
public class MbDiagram {
	private static final Logger logger = Logger.getLogger("SCENARIO");
	
	private ScenariosDao _scenarioDao = new ScenariosDao();
	
	private static final String NEXT_STATE_PREFIX = "NEXT_ON_";

	private Integer scenarioId;
	private AuthState[] states;
	private HashMap<Integer, AuthParam[]> stateParams;
	private HashMap<Integer, Integer> stateCodeToElemId;
	Long userSessionId = null;

	public MbDiagram() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		states = new AuthState[0];
		
		// FIXME: for tests only!!!
		scenarioId = 6;
	}
	
	public String makeXml() {
		int diagramId = 0;
		int layerId = 1;
		
		StringBuffer xml = new StringBuffer("<mxGraphModel>");
		xml.append("<root>");
		xml.append("<Diagram label=\"Auth scenario\" href=\"\" id=\"");
		xml.append(diagramId);
		xml.append("\">");
		xml.append("<mxCell/>");
		xml.append("</Diagram>");
		xml.append("<Layer label=\"Default Layer\" id=\"");
		xml.append(layerId);
		xml.append("\">");
		xml.append("<mxCell parent=\"");
		xml.append(diagramId);
		xml.append("\"/>");
		xml.append("</Layer>");
		
		// Diagram element ID must be unique, so we just increment it 
		// starting with 2 because 0 and 1 are already used  
		int elemId = 2;
		stateCodeToElemId = new HashMap<Integer, Integer>();
		elemId = getStates(elemId);
		
		int x = 0;
		int y = 0;
		int width = 80;
		int height = 40;
		int stepX = 120;
		int stepY = 60;
		
		for (AuthState state: states) {
			// make rectangle
			xml.append("<Rect label=\"");
			xml.append(state.getDescription());
			xml.append("\" href=\"\" id=\"");
			xml.append(stateCodeToElemId.get(state.getCode()));		// gets saved elemId
			xml.append("\" stateId=\"");
			xml.append(state.getId());
			xml.append("\" stateCode=\"");
			xml.append(state.getCode());
			xml.append("\">");
			xml.append("<mxCell vertex=\"1\" parent=\"");
			xml.append(layerId);
			xml.append("\">");
			xml.append("<mxGeometry x=\"");
			xml.append(x);
			xml.append("\" y=\"");
			xml.append(y);
			xml.append("\" width=\"");
			xml.append(width);
			xml.append("\" height=\"");
			xml.append(height);
			xml.append("\" as=\"geometry\"/>");
			xml.append("</mxCell>");
			xml.append("</Rect>");
			
			x += stepX;
			y += stepY;
			
			AuthParam[] params = stateParams.get(state.getCode());
			
			// draw connectors
			if (params != null) {
				for (AuthParam param: params) {
					// parameter considered as connector only if it has appropriate
					// prefix and its value is not null. Additional condition is 
					// availability of state which this parameter points on (so that
					// we don't draw a connector to a state that doesn't exist)
					if (param.getName().startsWith(NEXT_STATE_PREFIX) && param.getValue() != null
							&& param.getValueV().matches("\\d*")
							&& isStatePresent(param.getValueV())) {
						
					    // Connector label
						xml.append("<Connector label=\"");
					    xml.append(param.getName().substring(NEXT_STATE_PREFIX.length()));
					    
					    // Connector id
					    xml.append("\" href=\"\" id=\"");
					    xml.append(elemId++);
					    xml.append("\" paramId=\"");
					    xml.append(param.getParamId());
					    xml.append("\">");
					    xml.append("<mxCell edge=\"1\" parent=\"");
					    xml.append(layerId);

					    // State which this connector belongs to
					    xml.append("\" source=\"");
					    xml.append(stateCodeToElemId.get(state.getCode()));
					    
					    // State which this connector points on
					    xml.append("\" target=\"");
					    xml.append(stateCodeToElemId.get(param.getValueN().intValue()));
					    
					    xml.append("\">");
					    xml.append("<mxGeometry relative=\"1\" as=\"geometry\"/>");
					    xml.append("</mxCell>");
					    xml.append("</Connector>");
					}
				}
			}
		}

		xml.append("</root>");
		xml.append("</mxGraphModel>");

		return xml.toString();
	}
	
	private boolean isStatePresent(String code) {
		for (AuthState state: states) {
			if (state.getCode().toString().equals(code)) {
				return true;
			}
		}
		return false;
	}
	
	private int getStates(int elemId) {
		if (scenarioId != null) {
			try {
				SelectionParams params = new SelectionParams();

				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("scenarioId");
				filters[0].setOp(Operator.eq);
				filters[0].setValue(scenarioId.toString());
				
				params.setFilters(filters);
				params.setRowIndexEnd(-1);	// all states
				states = _scenarioDao.getStates( userSessionId, params);
				
				stateParams = new HashMap<Integer, AuthParam[]>(states.length);
				
				for (AuthState state: states) {

					// remember elemId used for this state with state code
					// as its key to get it when building diagram
					stateCodeToElemId.put(state.getCode(), elemId++);
					
					filters[0].setElement("stateId");
					filters[0].setOp(Operator.eq);
					filters[0].setValue(state.getId().toString());
					
					params.setFilters(filters);
					AuthParam[] authParams = _scenarioDao.getStateParams( userSessionId, params);
					stateParams.put(state.getCode(), authParams);
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("",e);
			}
		}
		return elemId;
	}

	public ArrayList<SelectItem> getScenarios() {
		ArrayList<SelectItem> items = null;
		try {
			Scenario[] scenarios = _scenarioDao.getScenarios( userSessionId, null);
			if (scenarios.length > 0) {
				items = new ArrayList<SelectItem>(scenarios.length);
				
				// we need this to show that no scenario selected if it's really so 
				if (scenarioId == null) items.add(new SelectItem(""));

				for (Scenario scenario: scenarios) {
					items.add(new SelectItem(scenario.getId(), scenario.getDescription()));
				}
			}
		} catch (Exception e) {
			logger.error("",e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		if (items == null) items = new ArrayList<SelectItem>(0);
		return items;
	}

	public Integer getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Integer scenarioId) {
		this.scenarioId = scenarioId;
	}

	private String xml;
	
	public void checkXml() {
		String formedXml = makeXml();
		System.out.println(formedXml);
		System.out.println("----------------------------------------");
		System.out.println(xml);
	}

	public String getXml() {
		if (xml == null) {
			xml = makeXml();
		}
//		xml = "<mxGraphModel><root><Diagram label=\"Auth scenario\" href=\"\" id=\"0\"><mxCell/></Diagram><Layer label=\"Default Layer\" id=\"1\"><mxCell parent=\"0\"/></Layer><Rect label=\"Rectangle\" href=\"\" id=\"2\"><mxCell vertex=\"1\" parent=\"1\"><mxGeometry x=\"60\" y=\"70\" width=\"80\" height=\"40\" as=\"geometry\"/></mxCell></Rect><Rect label=\"Rectangle\" href=\"\" id=\"3\"><mxCell vertex=\"1\" parent=\"1\"><mxGeometry x=\"260\" y=\"70\" width=\"80\" height=\"40\" as=\"geometry\"/></mxCell></Rect><Rect label=\"Rectangle\" href=\"\" id=\"4\"><mxCell vertex=\"1\" parent=\"1\"><mxGeometry x=\"260\" y=\"230\" width=\"80\" height=\"40\" as=\"geometry\"/></mxCell></Rect><Rect label=\"Rectangle\" href=\"\" id=\"5\"><mxCell vertex=\"1\" parent=\"1\"><mxGeometry x=\"450\" y=\"70\" width=\"80\" height=\"40\" as=\"geometry\"/></mxCell></Rect><Connector label=\"\" href=\"\" id=\"6\"><mxCell edge=\"1\" parent=\"1\" source=\"2\" target=\"3\"><mxGeometry relative=\"1\" as=\"geometry\"/></mxCell></Connector><Connector label=\"\" href=\"\" id=\"7\"><mxCell edge=\"1\" parent=\"1\" source=\"2\" target=\"4\"><mxGeometry relative=\"1\" as=\"geometry\"/></mxCell></Connector><Connector label=\"\" href=\"\" id=\"8\"><mxCell edge=\"1\" parent=\"1\" source=\"3\" target=\"5\"><mxGeometry relative=\"1\" as=\"geometry\"/></mxCell></Connector><Shape label=\"Shape\" href=\"\" id=\"10\"><mxCell style=\"rhombus\" vertex=\"1\" parent=\"1\"><mxGeometry x=\"450\" y=\"220\" width=\"60\" height=\"60\" as=\"geometry\"/></mxCell></Shape><Connector label=\"\" href=\"\" id=\"13\"><mxCell edge=\"1\" parent=\"1\" source=\"4\" target=\"10\"><mxGeometry relative=\"1\" as=\"geometry\"/></mxCell></Connector></root></mxGraphModel>";
		return xml;
	}

	public void setXml(String xml) {
		this.xml = xml;
	}
	
}
