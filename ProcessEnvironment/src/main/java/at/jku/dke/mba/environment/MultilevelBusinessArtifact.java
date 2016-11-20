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

import org.basex.core.Context;
import org.basex.data.Result;
import org.basex.query.QueryException;
import org.basex.query.QueryProcessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MultilevelBusinessArtifact {
	private final Logger logger = LoggerFactory.getLogger(MultilevelBusinessArtifact.class);

	private String name = null;
	private String collectionName = null;
	private String databaseName = null;

	private List<String> currentStatus = new ArrayList<String>();
	private List<String> datamodel = new ArrayList<String>();
	private List<String> concretizations = new ArrayList<String>();

	/**
	 * Takes names of database, collection and MBA and returns an instance that
	 * represents an MBA in the database.
	 * <p/>
	 * This constructor takes the minimum information required for a sensible
	 * representation of an MBA.
	 */
	public MultilevelBusinessArtifact(String database, String collection, String name) {
		this.databaseName = database;
		this.collectionName = collection;
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public String getCollectionName() {
		return collectionName;
	}

	public String getDatabaseName() {
		return databaseName;
	}

	public void setCollectionName(String collectionName) {
		this.collectionName = collectionName;
	}

	public void setDatabaseName(String databaseName) {
		this.databaseName = databaseName;
	}

	/**
	 * Adds a data element to the data model.
	 */
	public void addData(String dataElement) {
		if (!this.datamodel.contains(dataElement)) {
			this.datamodel.add(dataElement);
		}
	}

	/**
	 * Returns the contents of the data element with the given id.
	 * 
	 * @param id
	 *            the id of the data element
	 * @return the contents of the given data element
	 */
	public String getDataContents(String id) {
		String result = null;

		Context context = new Context();

		String query = "declare variable $data external;\n" + "declare variable $id external;\n"
				+ "if (fn:string($data/@id) = $id) then $data/node() else ()\n";

		try (QueryProcessor proc = new QueryProcessor(query, context)) {
			for (String data : this.datamodel) {
				proc.bind("data", data, "element()");
				proc.bind("id", id, "xs:string");

				Result queryResult = proc.execute();

				if (queryResult.size() > 0) {
					result = queryResult.serialize();
					break;
				}
			}
		} catch (QueryException e) {
			logger.error("Could not retrieve name of MBA.", e);
		} catch (IOException e) {
			logger.error("Could not query.", e);
			e.printStackTrace();
		} finally {
			if (context != null) {
				context.close();
			}
		}

		return result;
	}

	/**
	 * Adds a state to the MBA's list of active states.
	 * 
	 * @param stateId
	 *            the id of the state
	 */
	public void addCurrentState(String stateId) {
		if (!this.currentStatus.contains(stateId)) {
			this.currentStatus.add(stateId);
		}
	}

	public void removeCurrentState(String stateId) {
		this.currentStatus.remove(stateId);
	}

	public boolean isInState(String stateId) {
		return this.currentStatus.contains(stateId);
	}

	/**
	 * Adds a concretization to the MBA.
	 * 
	 * @param name
	 *            the name of the concretization
	 */
	public void addConcretization(String name) {
		if (!this.concretizations.contains(name)) {
			this.concretizations.add(name);
		}
	}

	public boolean hasConcretization(String mbaName) {
		return this.concretizations.contains(mbaName);
	}

	public List<String> getCurrentStatus() {
		return currentStatus;
	}

	public void setCurrentStatus(List<String> currentStatus) {
		this.currentStatus = currentStatus;
	}

	public List<String> getDatamodel() {
		return datamodel;
	}

	public void setDatamodel(List<String> datamodel) {
		this.datamodel = datamodel;
	}

	public List<String> getConcretizations() {
		return concretizations;
	}

	public void setConcretizations(List<String> concretizations) {
		this.concretizations = concretizations;
	}

	public Logger getLogger() {
		return logger;
	}

	public void setName(String name) {
		this.name = name;
	}

}
