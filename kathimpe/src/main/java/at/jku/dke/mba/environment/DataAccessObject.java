/**
 * --------------------------------
 * Multilevel Process Environment
 * --------------------------------
  
 * Copyright (C) 2015 Christoph Schütz
   
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

package at.jku.dke.mba.environment;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import javax.xml.namespace.QName;
import javax.xml.xquery.XQConnection;
import javax.xml.xquery.XQDataSource;
import javax.xml.xquery.XQException;
import javax.xml.xquery.XQItemType;
import javax.xml.xquery.XQPreparedExpression;
import javax.xml.xquery.XQResultSequence;

public class DataAccessObject {
	private final Logger logger = LoggerFactory.getLogger(DataAccessObject.class);

	private XQConnection connection = null;

	private XQConnection getConnection() {
		Properties properties = new Properties();

		if (connection == null || connection.isClosed()) {
			try (InputStream stream = getClass().getResourceAsStream("/xqj.properties");) {
				properties.load(stream);

				final String xqdsClassName = properties.getProperty("className");
				properties.remove("className");

				Class<?> xqdsClass = Class.forName(xqdsClassName);

				XQDataSource xqds = (XQDataSource) xqdsClass.newInstance();

				xqds.setProperties(properties);

				connection = xqds.getConnection();

				try {
					connection.setAutoCommit(false);
				} catch (Exception e) {
					logger.debug("No transaction management available. Set auto-commit to true.");
				}
			} catch (FileNotFoundException e) {
				logger.error("Could not find XQJ properties.", e);
			} catch (IOException e) {
				logger.error("Could not read XQJ properties.", e);
			} catch (ClassNotFoundException e) {
				logger.error("Wrong data source class in XQJ properties.", e);
			} catch (InstantiationException e) {
				logger.error("Problem with instantiating XQJ data source.", e);
			} catch (IllegalAccessException e) {
				logger.error("Problem with instantiating XQJ data source.", e);
			} catch (XQException e) {
				logger.error("Could not establish connection.", e);
			}
		}

		return connection;
	}

	/**
	 * Frees the resources of the database connection.
	 */
	public void close() {
		try {
			this.connection.close();
		} catch (XQException e) {
			logger.error("Could not close connection.", e);
		}
	}

	/**
	 * Returns an array of MBAs that have been updated.
	 * 
	 * @param dbName
	 *            the name of the database
	 * @param collectionName
	 *            the name of the collection
	 * @return an array of updated MBAs
	 */
	public MultilevelBusinessArtifact[] getUpdatedMultilevelBusinessArtifacts(String dbName, String collectionName) {
		List<MultilevelBusinessArtifact> returnValue = new LinkedList<MultilevelBusinessArtifact>();

	
		try (InputStream xquery = getClass().getResourceAsStream("/xquery/getUpdatedMultilevelBusinessArtifacts.xq")) {
			String[] result = runXQuery(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("collectionName", collectionName,
							getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);

		
			
			for (String xml : result) {
			
				MultilevelBusinessArtifact mba = this.xmlToMba(xml,dbName,collectionName);

				returnValue.add(mba);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Encountered an XQuery problem.", e);
		}

		return returnValue.toArray(new MultilevelBusinessArtifact[returnValue.size()]);
	}

	

	private MultilevelBusinessArtifact xmlToMba(String xml) {
		MultilevelBusinessArtifact returnValue = null;

		try (InputStream xqueryBaseData = getClass()
				.getResourceAsStream("/xquery/getMultilevelBusinessArtifactBaseData.xq");
				InputStream xqueryCurrentStatus = getClass()
						.getResourceAsStream("/xquery/getMultilevelBusinessArtifactCurrentStatus.xq");
				InputStream xqueryData = getClass().getResourceAsStream("/xquery/getMultilevelBusinessArtifactData.xq");
				InputStream xqueryConcretizations = getClass()
						.getResourceAsStream("/xquery/getMultilevelBusinessArtifactConcretizations.xq");) {
			String[] result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryBaseData);

			String mbaName = result[0];
			String dbName = result.length > 1 ? result[1] : null;
			String collectionName = result.length > 2 ? result[2] : null;

			returnValue = new MultilevelBusinessArtifact(dbName, collectionName, mbaName);

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryCurrentStatus);

			for (String stateId : result) {
				returnValue.addCurrentState(stateId);
			}

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryData);

			for (String dataElement : result) {
				returnValue.addData(dataElement);
			}

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryConcretizations);

			for (String concretization : result) {
				returnValue.addConcretization(concretization);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Encountered an XQuery problem.", e);
		}

		return returnValue;
	}
	
	
	private MultilevelBusinessArtifact xmlToMba(String xml, String dbName, String collectionName) {
		MultilevelBusinessArtifact returnValue = null;

		try (InputStream xqueryBaseData = getClass()
				.getResourceAsStream("/xquery/getMultilevelBusinessArtifactBaseData.xq");
				InputStream xqueryCurrentStatus = getClass()
						.getResourceAsStream("/xquery/getMultilevelBusinessArtifactCurrentStatus.xq");
				InputStream xqueryData = getClass().getResourceAsStream("/xquery/getMultilevelBusinessArtifactData.xq");
				InputStream xqueryConcretizations = getClass()
						.getResourceAsStream("/xquery/getMultilevelBusinessArtifactConcretizations.xq");) {
			String[] result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryBaseData);

			String mbaName = result[0];
			//String dbName = result.length > 1 ? result[1] : null;
			//String collectionName = result.length > 2 ? result[2] : null;

			returnValue = new MultilevelBusinessArtifact(dbName, collectionName, mbaName);

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryCurrentStatus);

			for (String stateId : result) {
				returnValue.addCurrentState(stateId);
			}

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryData);

			for (String dataElement : result) {
				returnValue.addData(dataElement);
			}

			result = runXQuery(
					new Binding[] { new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)), },
					xqueryConcretizations);

			for (String concretization : result) {
				returnValue.addConcretization(concretization);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Encountered an XQuery problem.", e);
		}

		return returnValue;
	}
	

	/**
	 * Returns an array of MBAs that have been newly created.
	 * 
	 * @param dbName
	 *            the name of the database
	 * @param collectionName
	 *            the name of the collection
	 * @return an array of new MBAs
	 */
	public MultilevelBusinessArtifact[] getNewMultilevelBusinessArtifacts(String dbName, String collectionName) {
		List<MultilevelBusinessArtifact> returnValue = new LinkedList<MultilevelBusinessArtifact>();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/getNewMultilevelBusinessArtifacts.xq")) {
			String[] result = runXQuery(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("collectionName", collectionName,
							getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);
				
			for (String xml : result) {
				MultilevelBusinessArtifact mba = this.xmlToMba(xml,dbName,collectionName);

				returnValue.add(mba);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Encountered an XQuery problem.", e);
		}

		return returnValue.toArray(new MultilevelBusinessArtifact[returnValue.size()]);
	}

	/**
	 * Creates a new database with a given name.
	 * 
	 * @param dbName
	 *            the name of the new database
	 */
	public void createDatabase(String dbName) {
		XQConnection con = this.getConnection();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/createDatabase.xq")) {

			runXQueryUpdate(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		}

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing macrostep.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	/**
	 * Drops the database with the given name.
	 * 
	 * @param dbName
	 *            the name of the database
	 */
	public void dropDatabase(String dbName) {
		XQConnection con = this.getConnection();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/dropDatabase.xq")) {

			runXQueryUpdate(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		}

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing macrostep.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	/**
	 * Initializes a given MBA, that is, adds the required SCXML variables for
	 * execution.
	 * 
	 * @param mba
	 *            the MBA to be initialized
	 */
	public void initMba(MultilevelBusinessArtifact mba) throws Exception {
		XQConnection con = this.getConnection();


		String url = "http://localhost:8984/initMBA/" + mba.getDatabaseName() + '/' + mba.getCollectionName() + '/'
				+ mba.getName();
		logger.info("url:" + url);
		callSomeRestService(url);

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing insert.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}
	
	
	
	public void startProcessNew(MultilevelBusinessArtifact mba) throws Exception {
		XQConnection con = this.getConnection();

		

		String url = "http://localhost:8984/initSCXML/" + mba.getDatabaseName() + '/' + mba.getCollectionName() + '/'
				+ mba.getName() + "/0";
		logger.info(url);
		callSomeRestService(url);

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing insert.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	/**
	 * Creates a new database with a given name.
	 * 
	 * @param dbName
	 *            the name of the new database
	 */
	public void insertAsCollection(String dbName, String xml) {
		XQConnection con = this.getConnection();

		try (InputStream xqueryInsert = getClass().getResourceAsStream("/xquery/insertAsCollection.xq");

				InputStream xqueryInitMbas = getClass().getResourceAsStream("/xquery/initMbasInCollection.xq");) {

			runXQueryUpdate(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)) },
					xqueryInsert);

			String collectionName = null;

			{
				MultilevelBusinessArtifact mba = this.xmlToMba(xml);
				collectionName = mba.getName();

				runXQueryUpdate(
						new Binding[] {
								new Binding("dbName", dbName,
										getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
								new Binding("collectionName", collectionName,
										getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
						xqueryInitMbas);
			}

			MultilevelBusinessArtifact[] mbaSeq = this.getMultilevelBusinessArtifacts(dbName, collectionName);

			for (MultilevelBusinessArtifact mba : mbaSeq) {
				try (InputStream xqueryInitScxml = getClass().getResourceAsStream("/xquery/initScxml.xq");) {
					runXQueryUpdate(mba, xqueryInitScxml);
				}
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		} catch (Exception e) {
			logger.error("Error: ", e.toString());
		}

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing insert.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	public void newinsertAsCollection(String dbName, String xml) {
		XQConnection con = this.getConnection();

		try (InputStream xqueryInsert = getClass().getResourceAsStream("/xquery/insertAsCollection.xq");

			) {

			runXQueryUpdate(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("mba", xml,
							getConnection().createElementType(new QName("mba"), XQItemType.XQITEMKIND_ELEMENT)) },
					xqueryInsert);

			String collectionName = null;

			{
				MultilevelBusinessArtifact mba = this.xmlToMba(xml);
				collectionName = mba.getName();

			}
			
			
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		} catch (Exception e) {
			logger.error("Error: ", e.toString());
		}

		
		
		
		
		
		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing insert.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
		
		
		
		
	}

	/**
	 * An MBA object with a given name from a database.
	 */
	public MultilevelBusinessArtifact getMultilevelBusinessArtifact(String dbName, String collectionName,
			String mbaName) {
		MultilevelBusinessArtifact returnValue = null;

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/getMultilevelBusinessArtifact.xq")) {
			String[] result = runXQuery(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("collectionName", collectionName,
							getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("mbaName", mbaName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);

			if (result.length > 0) {
				returnValue = this.xmlToMba(result[0]);
				returnValue.setCollectionName(collectionName);
				returnValue.setDatabaseName(dbName);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		}

		return returnValue;
	}

	public MultilevelBusinessArtifact[] getMultilevelBusinessArtifacts(String dbName, String collectionName) {
		List<MultilevelBusinessArtifact> returnValue = new LinkedList<MultilevelBusinessArtifact>();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/getMultilevelBusinessArtifacts.xq")) {
			String[] result = runXQuery(new Binding[] {
					new Binding("dbName", dbName, getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)),
					new Binding("collectionName", collectionName,
							getConnection().createAtomicType(XQItemType.XQBASETYPE_STRING)) },
					xquery);

			for (String xml : result) {
				MultilevelBusinessArtifact mba = this.xmlToMba(xml);
				mba.setDatabaseName(dbName);
				mba.setCollectionName(collectionName);

				returnValue.add(mba);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		}

		return returnValue.toArray(new MultilevelBusinessArtifact[returnValue.size()]);
	}

	/**
	 * Enqueues an event in a given MBA's external event queue.
	 * 
	 * @param mba
	 *            the mba that is concerned by the event
	 * @param externalEvent
	 *            a string representation of the XML element to be enqueued
	 */
	public void enqueueExternalEvent(MultilevelBusinessArtifact mba, String externalEvent) {
		XQConnection con = this.getConnection();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/enqueueExternalEvent.xq")) {

			runXQueryUpdate(mba,
					new Binding[] { new Binding("externalEvent", externalEvent,
							getConnection().createElementType(new QName("event"), XQItemType.XQITEMKIND_ELEMENT)) },
					xquery);
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		} catch (XQException e) {
			logger.error("Could not create element() type for binding.", e);
		}

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing macrostep.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}


	

	private void runXQueryUpdate(MultilevelBusinessArtifact mba, InputStream xquery) {
		XQConnection con = this.getConnection();

		XQPreparedExpression expression = null;

		try {
			expression = con.prepareExpression(xquery);

			logger.info("dbName, collectionName, mbaName " + mba.getDatabaseName() + "; " + mba.getCollectionName()
					+ ";" + mba.getName());
			expression.bindString(new QName("dbName"), mba.getDatabaseName(), null);
			expression.bindString(new QName("collectionName"), mba.getCollectionName(), null);
			expression.bindString(new QName("mbaName"), mba.getName(), null);

			XQResultSequence result = null;

			try {
				result = expression.executeQuery();
			} finally {
				if (result != null) {
					result.close();
				}
			}
		} catch (XQException e) {
			logger.error("Problem with XQuery.", e);
		} finally {
			if (expression != null) {
				try {
					expression.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	private void runXQueryUpdate(MultilevelBusinessArtifact mba, Binding[] bindings, InputStream xquery) {
		XQConnection con = this.getConnection();
		XQPreparedExpression expression = null;

		try {
			expression = con.prepareExpression(xquery);

			expression.bindString(new QName("dbName"), mba.getDatabaseName(), null);
			expression.bindString(new QName("collectionName"), mba.getCollectionName(), null);
			expression.bindString(new QName("mbaName"), mba.getName(), null);

			for (Binding binding : bindings) {
				expression.bindObject(new QName(binding.getVarName()), binding.getValue(), binding.getType());
			}

			XQResultSequence result = null;

			try {
				result = expression.executeQuery();
			} finally {
				if (result != null) {
					result.close();
				}
			}
		} catch (XQException e) {
			logger.error("Problem with XQuery.", e);
		} finally {
			if (expression != null) {
				try {
					expression.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	private void runXQueryUpdate(Binding[] bindings, InputStream xquery) {
		XQConnection con = this.getConnection();
		XQPreparedExpression expression = null;

		try {
			expression = con.prepareExpression(xquery);

			for (Binding binding : bindings) {
				expression.bindObject(new QName(binding.getVarName()), binding.getValue(), binding.getType());
			}

			XQResultSequence result = null;

			try {
				result = expression.executeQuery();
			} finally {
				if (result != null) {
					result.close();
				}
			}
		} catch (XQException e) {
			logger.error("Problem with XQuery.", e);
		} finally {
			if (expression != null) {
				try {
					expression.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}

	private String[] runXQuery(MultilevelBusinessArtifact mba, InputStream xquery) {
		XQConnection con = this.getConnection();
		XQPreparedExpression expression = null;

		List<String> returnValue = new LinkedList<String>();

		try {
			expression = con.prepareExpression(xquery);

			expression.bindString(new QName("dbName"), mba.getDatabaseName(), null);
			expression.bindString(new QName("collectionName"), mba.getCollectionName(), null);
			expression.bindString(new QName("mbaName"), mba.getName(), null);

			XQResultSequence result = null;

			try {
				result = expression.executeQuery();

				while (result.next()) {
					returnValue.add(result.getItemAsString(null));
				}
			} finally {
				if (result != null) {
					result.close();
				}
			}
		} catch (XQException e) {
			logger.error("Problem with XQuery.", e);
		} finally {
			if (expression != null) {
				try {
					expression.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}

		return returnValue.toArray(new String[returnValue.size()]);
	}

	private String[] runXQuery(Binding[] bindings, InputStream xquery) {
		XQConnection con = this.getConnection();
		XQPreparedExpression expression = null;

		List<String> returnValue = new LinkedList<String>();

		try {
			expression = con.prepareExpression(xquery);

			for (Binding binding : bindings) {
				expression.bindObject(new QName(binding.getVarName()), binding.getValue(), binding.getType());
			}

			XQResultSequence result = null;

			try {
				result = expression.executeQuery();

				while (result.next()) {
					returnValue.add(result.getItemAsString(null));
				}
			} finally {
				if (result != null) {
					result.close();
				}
			}
		} catch (XQException e) {
			logger.error("Problem with XQuery.", e);
		} finally {
			if (expression != null) {
				try {
					expression.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}

		return returnValue.toArray(new String[returnValue.size()]);
	}

	public void macrostepNew(MultilevelBusinessArtifact mba) throws Exception {
		XQConnection con = this.getConnection();
		// startProcess(mba);

		// String url = "http://localhost:8984/macroStep/"
		String url = "http://localhost:8984/initSCXML/"

				+ mba.getDatabaseName() + '/' + mba.getCollectionName() + '/' + mba.getName()+ "/0";

		logger.info("url:" + url);

		callSomeRestService(url);

		try {
			if (!con.getAutoCommit()) {
				con.commit();
			}
		} catch (XQException e) {
			logger.error("Error committing macrostep.", e);
		} finally {
			if (con != null) {
				try {
					con.close();
				} catch (XQException e) {
					// ignore
				}
			}
		}
	}



	public List<String> getNextEvent(MultilevelBusinessArtifact mba) {
		List<String> returnValue = new LinkedList<String>();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/fortesting.xq")) {
			String[] result = runXQuery(mba, xquery);

			for (String xml : result) {
				returnValue.add(xml);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		}

		return returnValue;
	};

	public List<String> getmbaagain(MultilevelBusinessArtifact mba) {
		List<String> returnValue = new LinkedList<String>();

		try (InputStream xquery = getClass().getResourceAsStream("/xquery/fortesting2.xq")) {
			String[] result = runXQuery(mba, xquery);

			for (String xml : result) {
				returnValue.add(xml);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		}

		return returnValue;
	};

	public List<String> getsomeXQUERY(MultilevelBusinessArtifact mba, String name) {
		List<String> returnValue = new LinkedList<String>();

		try (InputStream xquery = getClass().getResourceAsStream(name)) {
			String[] result = runXQuery(mba, xquery);

			for (String xml : result) {
				returnValue.add(xml);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		}

		return returnValue;
	};
	
	
	
	
	
	public List<String> getsomeXQUERY(String name) {
		List<String> returnValue = new LinkedList<String>();

		try (InputStream xquery = getClass().getResourceAsStream(name)) {
			String[] result = runXQuery(new Binding[]{},xquery);

			for (String xml : result) {
				returnValue.add(xml);
			}
		} catch (IOException e) {
			logger.error("Could not read XQuery file.", e);
		}

		return returnValue;
	};
	
	
	public void callSomeRestService(String url) throws Exception {

		URL obj = new URL(url);
		HttpURLConnection con = (HttpURLConnection) obj.openConnection();

		Object responseCode = con.getResponseCode();

	}

	private class Binding {
		private String varName = null;
		private Object value = null;
		private XQItemType type = null;

		public Binding(String varName, Object value, XQItemType type) {
			this.varName = varName;
			this.value = value;
			this.type = type;
		}

		public String getVarName() {
			return varName;
		}

		public Object getValue() {
			return value;
		}

		public XQItemType getType() {
			return type;
		}
	}
}
