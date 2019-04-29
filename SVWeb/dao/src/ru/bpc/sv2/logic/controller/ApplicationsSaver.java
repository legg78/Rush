package ru.bpc.sv2.logic.controller;

import java.sql.SQLException;

import java.util.List;

import org.apache.log4j.Logger;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.controller.ApplicationController;


public class ApplicationsSaver {

	long dataId;
	long currVal;
	long appId;
	int step = ApplicationConstants.DATA_SEQUENCE_STEP;
	int count;
	
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	public ApplicationsSaver (Long appId) {
		this.appId = appId;
	}
	
	public void initArray(SqlMapSession ssn, ApplicationElement appTree, List<ApplicationRec> appAsArray) 
	throws SQLException {
		currVal = ApplicationController.getNextDataId(ssn, appId);
		currVal = currVal - step;
		count = 1;
		if (appTree.getDataId() == null || appTree.getDataId() == 0L) {
			appTree.setDataId(currVal + count);
			logger.trace("New root dataId = " + appTree.getDataId());
			count++;
		}
		//root element always has dataId!!!
		fillArray( ssn, appTree, appAsArray);
	}
	
	private void fillArray(SqlMapSession ssn, ApplicationElement appTree, List<ApplicationRec> appAsArray)
	throws SQLException {
		if (!appTree.getContent()) {
				ApplicationElement el = new ApplicationElement();
				appTree.clone(el);
				// we use another element "el" just to prevent 
				// modification of the initial appTree 
				if (!appTree.isComplex()) {
					if (appTree.getValueN()==null && appTree.getValueD()==null) {
						if (appTree.getValueV() == null	|| (appTree.getValueV()!=null && appTree.getValueV().trim().equals(""))) {
							logger.trace("Element/id: " + el.getName()+ "/" + el.getId() + ";Set seq number = null; previous seqNum = "+el.getInnerId()+";id=" + el.getDataId());
							el.setInnerId(null);							
						}
					}
				}
				if (el.getInnerId() != null && el.getInnerId() < 0) {
					el.setInnerId(null);
				}
				ApplicationRec rec = new ApplicationRec(el);
				appAsArray.add(rec);				
			
		}
//		System.out.println(appTree.getName() + " : " + appTree.getDataId() + " : " + appTree.getParentDataId() + " : " + appTree.getValue());
		for ( ApplicationElement child : appTree.getChildren() )
		{
			if (!child.getContent()) {
				if (count == step) {
					//need more dataIds from sequence
					resetCount(ssn);
				}
				child.setParentDataId(appTree.getDataId());
				logger.trace("Element/id: " + child.getName()+ "/" + child.getId() + "; seqNum = "+child.getInnerId()+";id=" + child.getDataId());
				if (child.getDataId() == null || child.getDataId().equals(new Long(0))) {
					logger.trace("Setting dataId");
					child.setDataId(currVal + count);	
					logger.trace("New dataId = " + child.getDataId());
					count++;
				}				
				fillArray( ssn, child, appAsArray );				
			}
		}
		
	}
	
	private void resetCount(SqlMapSession ssn) 
	throws SQLException {
		currVal = ApplicationController.getNextDataId(ssn, appId);
		currVal = currVal - step;
		count = 1;
	}
	
	public void initDataIds(SqlMapSession ssn, ApplicationElement appTree) 
	throws SQLException {
		currVal = ApplicationController.getNextDataId(ssn, appId);
		currVal = currVal - step;
		count = 0;
		//root element always has dataId!!!
		if (!appTree.getContent()) {
			if (count == step) {
				//need more dataIds from sequence
				resetCount(ssn);
			}
			if (appTree.getDataId() == null || appTree.getDataId().equals(new Long(0))) {
				appTree.setDataId(currVal + count);	
				count++;
			}
			fillDataIds(ssn, appTree);	
		}
	}
	
	private void fillDataIds(SqlMapSession ssn, ApplicationElement appTree) 
	throws SQLException {
		for ( ApplicationElement child : appTree.getChildren() )
		{
			if (!child.getContent()) {
				if (count == step) {
					//need more dataIds from sequence
					resetCount(ssn);
				}
				if (child.getDataId() == null || child.getDataId().equals(new Long(0))) {
					child.setDataId(currVal + count);	
					count++;
				}
				if (child.isComplex()){
					fillDataIds(ssn, child);
				}
			}
		}
	}
}
