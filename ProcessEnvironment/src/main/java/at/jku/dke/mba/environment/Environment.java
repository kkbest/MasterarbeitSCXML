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

import static org.quartz.JobBuilder.newJob;
import static org.quartz.SimpleScheduleBuilder.repeatSecondlyForever;
import static org.quartz.TriggerBuilder.newTrigger;

import org.quartz.impl.StdSchedulerFactory;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;

public class Environment implements Runnable {
  final Logger logger = LoggerFactory.getLogger(Environment.class);
  
  @Override
  public void run() {    
    try {      
      Properties properties = new Properties();
      
      try (InputStream stream = Environment.class.getResourceAsStream("/environment.properties");) {
        properties.load(stream);
      }
      
      final String database = properties.getProperty("database");
      final String[] collections = properties.getProperty("collections").split(",");
      final int repeatFrequency = Integer.parseInt(properties.getProperty("repeatFrequency"));
      
      Scheduler scheduler = StdSchedulerFactory.getDefaultScheduler();
      
      JobDetail job = newJob(Enactment.class)
          .withIdentity("enactment", "enactmentGroup")
          .build();

      job.getJobDataMap().put("database", database);
      job.getJobDataMap().put("collections", collections);
      
      Trigger trigger = newTrigger()
          .withIdentity("enactmentTrigger", "enactmentGroup")
          .startNow()
          .withSchedule(repeatSecondlyForever(repeatFrequency))
          .build();
      
      scheduler.scheduleJob(job, trigger);
      
      scheduler.start();
    } catch (SchedulerException se) {
      LoggerFactory.getLogger(Environment.class).error("Problem with job scheduler.", se);
    } catch (IOException e) {
      logger.error("Could not find environment properties.", e);
    }
  }
  
  /**
   * The main loop of the business process environment.
   * @param args empty
   */
  public static void main(String[] args) {
    new Thread(new Environment()).start();
  }

}
