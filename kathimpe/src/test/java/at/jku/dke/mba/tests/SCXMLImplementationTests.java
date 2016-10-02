package at.jku.dke.mba.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.quartz.JobBuilder.newJob;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.apache.commons.io.IOUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobKey;
import org.quartz.Scheduler;
import org.quartz.impl.JobExecutionContextImpl;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.spi.ThreadExecutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import at.jku.dke.mba.environment.DataAccessObject;
import at.jku.dke.mba.environment.Enactment;
import at.jku.dke.mba.environment.Environment;
import at.jku.dke.mba.environment.MultilevelBusinessArtifact;
import at.jku.dke.mba.environment.TestEnactment;

public class SCXMLImplementationTests {
	private final Logger logger = LoggerFactory.getLogger(EnvironmentTest.class);

	private DataAccessObject dao = new DataAccessObject();

	@Before
	public void setUp() {
		dao.getsomeXQUERY("/xquery/fortesting10.xq");

		dao.createDatabase("myMBAse");
		
	}

	@After
	public void tearDown() {
		logger.info("teardown");
		dao.close();

		
	}

	public void setUpDb(String resource, String dbName, String collectionName) {

		
		try (InputStream xml = getClass().getResourceAsStream(resource)) {
			dao.newinsertAsCollection("myMBAse", IOUtils.toString(xml));
			logger.info("String: " + resource);

		} catch (IOException e) {
			logger.error("Could not read XML file.", e);
		} catch (Exception e) {
			logger.error("Could do file.", e);
		}

	}

	public void initDb(String dbName, String collectionName) {
		MultilevelBusinessArtifact[] mbaSeq = dao.getMultilevelBusinessArtifacts(dbName, collectionName);
		logger.info("test" + mbaSeq.length);
		for (MultilevelBusinessArtifact mba : mbaSeq) {

			logger.info("MBA:" + mba.getCollectionName() + mba.getDatabaseName() + mba.getName());
			try {
				dao.initMba(mba);
			} catch (Exception e) {
				
				e.printStackTrace();
			}
		}

	}

	public void startProcess(String dbName, String collectionName) {
		MultilevelBusinessArtifact[] mbaSeq = dao.getMultilevelBusinessArtifacts(dbName, collectionName);

		for (MultilevelBusinessArtifact mba : mbaSeq) {

			logger.info("MBA:" + mba.getCollectionName() + mba.getDatabaseName() + mba.getName());
			try {
				dao.initMba(mba);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}

	@Test
	public void testGuard() throws Exception {

		try (InputStream xml = getClass().getResourceAsStream("/xml/academic_simplen.xml")) {
			dao.insertAsCollection("myMBAse", IOUtils.toString(xml));
		} catch (IOException e) {
			logger.error("Could not read XML file.", e);
		}
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		dao.enqueueExternalEvent(mba,
				"<event name=\"setDegree\" xmlns=\"\">" + " <degree xmlns=\"\">MA</degree>" + "</event>");

		dao.macrostepNew(mba);

		assertNull(mba.getDataContents("degree"));
	};
	
	@Test
	public void test355() throws Exception {

		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test355.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);
		
	MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
	dao.startProcessNew(mba); 
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		assertFalse(mba.isInState("fail"));
		assertTrue(mba.isInState("pass"));

	};

	@Test
	public void test576() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test576.xml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("s11p112"));
		assertTrue(mba.isInState("s11p122"));

	}

	//@Test
	public void test364() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test364a.xml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		logger.info("before");

		dao.startProcessNew(mba);
		logger.info("after");
		
		
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		logger.info("statusnochmal" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test372() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test372.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		logger.info("test" + mba.getDataContents("1"));

		logger.info("statusnochmal" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));

	}

	@Test
	public void test570() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test570.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		logger.info("statusnochmal" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test375() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test375.xml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test376() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test376.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("statusnochmal" + mba.getCurrentStatus());

		assertTrue(mba.isInState("s3"));
		assertFalse(mba.isInState("s1"));

	}

	@Test
	public void test377() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test377.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("statusnochmal" + mba.getCurrentStatus());
		assertTrue(mba.isInState("s3"));
		assertFalse(mba.isInState("s1"));

	}

	//@Test
	public void test378() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test378.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");
	assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));
	

	}

	@Test
	public void test387() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test387.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("statusnochmal" + mba.getCurrentStatus());
		assertTrue(mba.isInState("s5"));
		assertFalse(mba.isInState("s1"));

	}

	@Test
	public void test579() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test579a.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		dao.enqueueExternalEvent(mba, "<event name=\"timeout\" xmlns=\"\"/>");
		dao.macrostepNew(mba);

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	
	//@Test
	public void test580() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test580.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		//dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test388() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test388.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");
		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test396() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test396.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");
		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test399() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test399.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("statusnochmal" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test401() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test401.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test402() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test402.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test403a() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test403a.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test403b() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test403b.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test403c() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test403c.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test404() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test404.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test405() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test405.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test406() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test406.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test407() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test407.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test409() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test409.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test411() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test411.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test412() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test412.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test413() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test413.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test415() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test415.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("final"));

	}

	@Test
	public void test416() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test416.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test417() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test417.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test419() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test419.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test421() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test421.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test422() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test422.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test423() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test423.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test503() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test503.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test504() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test504.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test505() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test505.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test506() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test506.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test533() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test533.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test144() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test144.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test147() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test147.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test148() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test148.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test149() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test149.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test150() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test150.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test151() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test151.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test152() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test152.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test153() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test153.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test155() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test155.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test156() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test156.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test525() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test525.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test158() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test158.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test159() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test159.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test276() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test276.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	     t.execute(null);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test277() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test277.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test279() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test279.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test280() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test280.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test550() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test550.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test551() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test551.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test552() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test552.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test286() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test286.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test287() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test287.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test487() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test487.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));
	};

	@Test
	public void test294() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test294.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test527() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test527.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test528() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test528.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test529() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test529.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test298() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test298.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test343() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test343.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test488() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test488.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test301() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test301.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test302() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test302.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test303() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test303.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test304() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test304.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test307() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test307.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test309() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test309.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test310() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test310.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test311() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test311.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test312() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test312.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test313() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test313.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test314() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test314.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test344() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test344.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test318() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test318.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test319() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test319.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test321() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test321.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test322() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test322.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test323() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test323.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test324() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test324.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test325() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test325.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test326() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test326.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test329() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test329.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test330() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test330.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test331() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test331.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test332() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test332.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test333() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test333.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test335() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test335.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test336() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test336.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);
		
		
		TestEnactment t = new TestEnactment();
		  t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		
	assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test337() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test337.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test338() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test338.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		
	    TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
		

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		logger.info("something");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test339() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test339.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test342() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test342.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test346() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test346.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test172() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test172.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test173() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test173.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test174() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test174.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test175() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test175.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test176() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test176.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test178() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test178.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test179() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test179.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test183() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test183.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	 @Test
	public void test185() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test185.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	 @Test
	public void test186() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test186.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test187() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test187.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test194() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test194.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test198() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test198.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test199() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test199.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test200() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test200.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test201() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test201.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test205() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test205.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test521() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test521.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test553() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test553.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test207() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test207.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test208() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test208.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test210() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test210.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test215() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test215.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		
		
	    TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test216() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test216.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);
		
		Properties properties = new Properties();
	      
	      try (InputStream stream = Environment.class.getResourceAsStream("/environment.properties");) {
	        properties.load(stream);
	      }	
		 
	     
	    TestEnactment t = new TestEnactment();
	     t.execute(null);
	      t.execute(null);
		

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		logger.info("something");
		
		
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));
		
	}

	@Test
	public void test220() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test220.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test223() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test223.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test224() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test224.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	     t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test225() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test225.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test226() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test226.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	     t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test228() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test228.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test229() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test229.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test230() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test230.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("final"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test232() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test232.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test233() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test233.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test234() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test234.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test235() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test235.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	     t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test236() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test236.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	     t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("s2"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test237() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test237.txml", dbName, collectionName);
     this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	    t.execute(null);
	    MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		
		dao.enqueueExternalEvent(mba,
				"<event name=\"hallo1\" xmlns=\"\">" + "</event>");
		dao.macrostepNew(mba);
		
		t.execute(null);
		dao.enqueueExternalEvent(mba,
				"<event name=\"hallo3\" xmlns=\"\">" + "</event>");
		t.execute(null); 
		 mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test239() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test239.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      t.execute(null);
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}
	
	@Test
	public void test240() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test240.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test241() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test241.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test242() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test242.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test243() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test243.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	     t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test244() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test244.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test245() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test245.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test247() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test247.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test250() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test250.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		
		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      dao.enqueueExternalEvent(mba,
					"<event name=\"input\" xmlns=\"\">" + "</event>");
	      t.execute(null);
	      t.execute(null);
	      
	    mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
					"InformationSystems");
			

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test252() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test252.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	     // t.execute(null);
	     // t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test253() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test253.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());
		
		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test530() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test530.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test554() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test554.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	  	dao.enqueueExternalEvent(mba,
				"<event name=\"timer\" xmlns=\"\">" + "</event>");
	  	 t.execute(null);
		 mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test436() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test436.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test278() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test278.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test444() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test444.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test445() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test445.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test448() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test448.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test449() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test449.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test451() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test451.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test452() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test452.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test453() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test453.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test456() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test456.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test446() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test446.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test557() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test557.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test558() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test558.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test560() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test560.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test578() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test578.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test561() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test561.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	// @Test
	public void test562() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test562.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test569() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test569.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test457() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test457.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test459() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test459.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test460() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test460.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test189() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test189.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test190() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test190.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test191() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test191.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);

	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		


		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test192() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test192.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		
		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test193() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test193.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test347() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test347.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		
		TestEnactment t = new TestEnactment();
	      t.execute(null);
	      t.execute(null);
	      t.execute(null);
	      
		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		
		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test348() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test348.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test349() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test349.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test350() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test350.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test351() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test351.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test352() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test352.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test354() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test354.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test495() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test495.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test496() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test496.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test500() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test500.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	@Test
	public void test501() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test501.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test509() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test509.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test510() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test510.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test513() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		 this.setUpDb("/scxmlcases/test513.txml", dbName, collectionName);
		 this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test518() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test518.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test519() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test519.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test520() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test520.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}
	
	
	


	//@Test
	public void test522() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test522.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test531() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test531.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test532() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test532.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test534() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test534.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

	//@Test
	public void test567() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test567.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}

    //@Test
	public void test577() throws Exception {
		String dbName = "myMBAse";
		String collectionName = "JohannesKeplerUniversity";

		this.setUpDb("/scxmlcases/test577.txml", dbName, collectionName);
		this.initDb(dbName, collectionName);

		MultilevelBusinessArtifact mba = dao.getMultilevelBusinessArtifact(dbName, collectionName,
				"InformationSystems");
		dao.startProcessNew(mba);
		mba = dao.getMultilevelBusinessArtifact(dbName, collectionName, "InformationSystems");

		logger.info("status" + mba.getCurrentStatus());

		assertTrue(mba.isInState("pass"));
		assertFalse(mba.isInState("fail"));

	}
}
