// Disabled functionality related to SVN as project is switched to Git
//package ru.bpc.sv2.ui.utils;
//
//
//import java.io.File;
//import java.io.FileWriter;
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.List;
//
//import org.apache.log4j.Logger;
//import org.tmatesoft.svn.core.SVNCommitInfo;
//import org.tmatesoft.svn.core.SVNDepth;
//import org.tmatesoft.svn.core.SVNException;
//import org.tmatesoft.svn.core.auth.BasicAuthenticationManager;
//import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
//import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
//import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
//import org.tmatesoft.svn.core.internal.wc.DefaultSVNOptions;
//import org.tmatesoft.svn.core.wc.SVNClientManager;
//import org.tmatesoft.svn.core.wc.SVNCommitClient;
//import org.tmatesoft.svn.core.wc.SVNRevision;
//import org.tmatesoft.svn.core.wc.SVNUpdateClient;
//import org.tmatesoft.svn.core.wc.SVNWCClient;
//
//import ru.bpc.sv2.process.SessionFile;
//
//public class SvnCommit {
//private String path;
//private String username;
//private String password;
//private boolean locked = false;
//private static final Logger logger = Logger.getLogger("COMMON");
//
//public SvnCommit(String path, String username, String password) throws SVNException {
//	/*
//	 * Initialize the library. It must be done before calling any
//	 * method of the library.
//	 */
//        setupLibrary();
//        this.path = path;
//        this.username = username;
//        this.password = password;
//        logger.debug("SvnCommit construct");
//    }
//
//
//    /*
//     * Initializes the library to work with a repository via
//     * different protocols.
//     */
//    private static void setupLibrary() {
//        /*
//         * For using over http:// and https://
//         */
//        DAVRepositoryFactory.setup();
//        /*
//         * For using over svn:// and svn+xxx://
//         */
//        SVNRepositoryFactoryImpl.setup();
//
//        /*
//         * For using over file:///
//         */
//        FSRepositoryFactory.setup();
//    }
//
//    public void commitFiles(List<SessionFile> files, String svnComments) throws Exception {
//    	List <String> changes = new ArrayList<String>();
//    	logger.debug("fucntion commitFiles");
//    	update(path);
//    	locked = false;
//    	for (SessionFile file : files) {
//    		//get file name
//    		String fileName = file.getFileName();
//    		String fileContent = file.getFileContents();
//
//    		String fileNameWithoutExt = "";
//    		boolean isSql = false;
//    		if (fileName != null) {
//        		int ind = fileName.indexOf(".sql");
//        		if (ind != -1) {
//        			isSql = true;
//        		} else {
//        			ind = fileName.indexOf(".xml");
//        		}
//        		if (ind != -1) fileNameWithoutExt = fileName.substring(0, ind);
//        	}
//    		//Check locks local copy - file with extension "lok" exists
//    		String separator = System.getProperty("file.separator");
//    		String adjustPath = path;
//    		if (!isSql) {
//    			adjustPath = path + separator + "clob";
//    		}
//    		String lokFilePath = adjustPath + separator + fileNameWithoutExt + ".lok";
//    		File lokFile = new File(lokFilePath);
//    		if(lokFile.exists()) {
//    			//file has been locked
//    			locked = true;
//    			int count = 1;
//    			while (count <= 6) {
//    				Thread.sleep(5000);
//    				if (!lokFile.exists()) {
//    					locked = false;
//    					break;
//    				}
//    				count++;
//    			}
//
//    			if (lokFile.exists()) {
//    				throw new IOException("File is still locked. Session timeout!");
//    			}
//    		}
//			//no locking - create this file
//			if (!lokFile.createNewFile()) throw new IOException("Cannot create lok file in " + lokFilePath);
//			//check file exist
//			String filePath = adjustPath + separator + fileName;
//			File originFile = new File(filePath);
//			if (!originFile.exists()) {
//				// create new file
//				if (!originFile.createNewFile()) throw new IOException("Cannot create file " + filePath);
//				changes.addAll(writeToFile(originFile, fileContent, false));
//			} else {
//				if (isSql) {
//					// append data to the end of file
//					changes.addAll(writeToFile(originFile, fileContent, true));
//				} else {
//					changes.addAll(writeToFile(originFile, fileContent, false));
//				}
//			}
//    		//remove lok file
//    		if (!lokFile.delete()) throw new IOException("Cannot delete lok file " + lokFilePath);
//    	}
//    	try{
//    		sendCommitToClient(path, username, password, svnComments);
//    	}catch (SVNException e){
//    		revertChanges(path, changes);
//    		throw e;
//    	}
//    }
//
//    private void revertChanges(String path, List<String> changes) throws SVNException{
//
//    	logger.debug("begin rever");
//		BasicAuthenticationManager authManager = new BasicAuthenticationManager(
//				username, password);
//		File localPath = new File(path);
//		logger.debug("path = " + path);
//		for (String str :changes){
//			logger.debug("string = " + str);
//		}
//    try{
//    	SVNWCClient wcClient = new SVNWCClient(authManager, null);
//    	wcClient.doRevert(localPath, true);
//    }catch (SVNException e){
//    	logger.debug("Exception " + e.getMessage());
//    	throw e;
//    }
//    logger.debug("success revert");
//    }
//
//    private List<String> writeToFile(File file, String content, boolean isAppend) {
//    	List <String> changes = new ArrayList<String>();
//		try {
//			FileWriter fw = new FileWriter(file, isAppend); // the true will
//															// append the new
//															// data
//			String fileContent = content == null ? "" : content;
//			if (!isAppend) {
//				fw.write(fileContent);
//				changes.add(fileContent);
//			} else {
//				fw.write("\n" + fileContent);// appends the string to the file
//				changes.add("\n" + fileContent);
//			}
//			fw.close();
//		} catch (IOException ioe) {
//			System.err.println("IOException: " + ioe.getMessage());
//		}
//		return changes;
//    }
//
//    private void sendCommitToClient(String path, String username,
//			String password, String svnComments) throws SVNException {
//    	logger.debug("begin commit");
//		BasicAuthenticationManager authManager = new BasicAuthenticationManager(
//				username, password);
//		File localPath = new File(path);
//		// SVN Commit
//		SVNCommitClient client = new SVNCommitClient(authManager, null);
//		SVNCommitInfo info;
//		try {
//			SVNWCClient wcClient = new SVNWCClient(authManager, null);
//			wcClient.doAdd(localPath, true, false, false, SVNDepth.INFINITY,
//					false, false, false);
//			info = client.doCommit(new File[] { localPath }, false, svnComments, false, true);
//			System.out.println("Revision " + info.getNewRevision());
//		} catch (SVNException e) {
//			logger.debug("Exception " + e.getMessage());
//			e.printStackTrace();
//			throw e;
//		}
//		logger.debug("success commit");
//	}
//
//
//	private void update(String path) throws SVNException {
//		logger.debug("begin update");
//		 final File localProjectDirectory = new File(path);
//		 BasicAuthenticationManager authManager = new BasicAuthenticationManager(
//					username, password);
//		    final SVNClientManager cm = SVNClientManager.newInstance(new DefaultSVNOptions());
//		    cm.setAuthenticationManager(authManager);
//		    final SVNUpdateClient uc = cm.getUpdateClient();
//		    final SVNRevision svnHeadRevision = SVNRevision.HEAD;
//		    final SVNDepth svnRecursiveDepth = SVNDepth.fromRecurse(true);
//		    final boolean allowUnversionedObstructions = false;
//		    final boolean depthIsSticky = true;
//
//	    try{
//	    	//uc.doUpdate(localProjectDirectory, svnHeadRevision, svnRecursiveDepth, allowUnversionedObstructions, depthIsSticky);
//	    	uc.doUpdate(localProjectDirectory, svnHeadRevision, svnRecursiveDepth, allowUnversionedObstructions, depthIsSticky);
//	    }catch (SVNException e){
//	    	logger.debug("Exception " + e.getMessage());
//	    	throw e;
//	    }
//	    logger.debug("success update");
//
//    }
//
//	public String getPath() {
//		return path;
//	}
//
//	public void setPath(String path) {
//		this.path = path;
//	}
//
//	public String getUsername() {
//		return username;
//	}
//
//	public void setUsername(String username) {
//		this.username = username;
//	}
//
//	public String getPassword() {
//		return password;
//	}
//
//	public void setPassword(String password) {
//		this.password = password;
//	}
//
//	public boolean isLocked() {
//		return locked;
//	}
//
//	public void setLocked(boolean locked) {
//		this.locked = locked;
//	}
//
//}
//