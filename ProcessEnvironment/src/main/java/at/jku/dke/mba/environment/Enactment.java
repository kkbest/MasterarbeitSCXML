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

import java.util.LinkedList;
import java.util.List;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Enactment implements Job {
  private final Logger logger = LoggerFactory.getLogger(Enactment.class); 

  @Override
  public void execute(JobExecutionContext context) throws JobExecutionException {
    JobDataMap data = context.getJobDetail().getJobDataMap();
    DataAccessObject dao = new DataAccessObject();
    
    
    
    List<String>  dbNameInv = new LinkedList<String>();
    dbNameInv.addAll(dao.getsomeXQUERY( "/xquery/getInvokeDbs.xq"));
    logger.info("number of Invoke DBS" + dbNameInv.size());
    
    for (String dbNameInvoke : dbNameInv)
    {
    	MultilevelBusinessArtifact[] newMbas = 
    	          dao.getNewMultilevelBusinessArtifacts(dbNameInvoke, "invoke");
    	
    	
    	 for (MultilevelBusinessArtifact mba : newMbas) {
    	        logger.info("Initializing newly created MBA " + mba.getName() + ".");
    	        try {
    				dao.initMba(mba);
    			} catch (Exception e) {
    				// TODO Auto-generated catch block
    				e.printStackTrace();
    			}
    	        //Get created MBAS ? 
    	        //logger.info(" test" + dao.getmbaagain(mba));
    	      }
       
    MultilevelBusinessArtifact[] updatedMbas = 
            dao.getUpdatedMultilevelBusinessArtifacts(dbNameInvoke, "invoke");
        
	
        for (MultilevelBusinessArtifact mba : updatedMbas) {
          logger.info("Conducting microstep for " + mba.getName() + ".");
          try {
  			dao.startProcessNew(mba);
  		} catch (Exception e) {
  			// TODO Auto-generated catch block
  			e.printStackTrace();
  		}
        }
    }
        
    
    
    String dbName = data.getString("database");
    String[] collectionNames = (String[]) data.get("collections");
    
    logger.info("normalCollAnzahl" + collectionNames.length);
    for (String collectionName : collectionNames) {
      MultilevelBusinessArtifact[] newMbas = 
          dao.getNewMultilevelBusinessArtifacts(dbName, collectionName);
      logger.info("NormalnewSize" + newMbas.length);
      
      for (MultilevelBusinessArtifact mba : newMbas) {
        logger.info("NormalInitializing newly created MBA " + mba.getName() + ".");
        try {
			dao.initMba(mba);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        //Get created MBAS ? 
        
      }
      
      MultilevelBusinessArtifact[] updatedMbas = 
          dao.getUpdatedMultilevelBusinessArtifacts(dbName, collectionName);
      logger.info("NormalupdatedSize" + updatedMbas.length);;
      for (MultilevelBusinessArtifact mba : updatedMbas) {
        try {
        	logger.info("Conducting microstep for " + mba.getDatabaseName() + ";" + mba.getCollectionName()  + "; " + mba.getName() + ".");
        	dao.startProcessNew(mba);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
      }
    }
    
    dao.close();
  }

}
