package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.logic.utility.JndiUtils;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Vector;

public class ConnectionPool {
	private Vector<Connection> availableConns = new Vector<Connection>();
    private Vector<Connection> usedConns = new Vector<Connection>();

    public ConnectionPool(int number) throws SQLException {
        for (int i = 0; i < number; i++) {
            availableConns.addElement(getConnection());
        }
    }

    private Connection getConnection() throws SQLException {
		Connection connection = JndiUtils.getConnection();
		connection.setAutoCommit(false);
        return connection;
    }

    public Connection retrieve() throws SQLException{
    	Connection newConn = null;
    	synchronized(this){
	        if (availableConns.size() == 0) {
	            newConn = getConnection();
	        } else {
	            newConn = (Connection) availableConns.lastElement();
	            availableConns.removeElement(newConn);
	        }
	        usedConns.addElement(newConn);
    	}
        return newConn;
    }

    public void putback(Connection c) throws NullPointerException {
    	synchronized(this){
		    if (c != null) {
		        if (usedConns.removeElement(c)) {
		            availableConns.addElement(c);
		        } else {
		            throw new NullPointerException("Connection not in the usedConns array");
		        }
		    } 
    	}
    }

    public int getAvailableConnsCnt() {
        return availableConns.size();
    }
    
    public void closeConnections(){
    	for(Connection conn:availableConns){
    		try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}
    }
}
