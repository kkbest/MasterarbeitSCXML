# MasterarbeitSCXML

The Masterarbeit SCXML provides a set of XQuerfy functions for the interpretation of State Chart XML (SCXML) documents.
It also includes the Multilevel business process envinroment for calling this functions automatically. 

This work is based on the work from Schuetz [4,5,6]
#Prerequisites

The SCXML interpreter works in conjunction with an XML database management system. Download and install an XML database management system.

We recommend BaseX 8.1.1: http://basex.org/

# Installation 


##1.) Install the required XQuery modules 

Checkout the git repository and run the .bxs script in order to install the module. Open the shell, change to the root directory of the repository on your disk and run the following command:

basex installmodules.bxs

##2.) Install the Worklist Handler 

(static folder into webapp folder of BASEX

##3.) Start the XML database management system in server mode

The process environment will access the XML database as a server. You don't actually need to create a database to run the examples/test cases.

For BaseX see:

http://docs.basex.org/wiki/Startup#Server

The process Engine is now usable


##4.) Resolve dependencies in Java Project 

The multilevel business process environment requires several third-party libraries. We recommend using maven to resolve dependencies. A pom.xml file is provided in the root directory of the repository.

##5.)Configuration

In the MultilevelProcessEnvironment directory of this repository, there are several properties file that govern the behavior of the environment. Change the default values to adapt the environment to your specific needs. These properties files must be in the classpath when running the application.

src/main/resources/xqj.properties

The xqj.properties file holds the parameters for the database connection and has the following properties:

className: The name of the concrete class that implements the abstract XQJ data source class. Default class is the BaseX data source.
serverName: The address/name of the server that hosts the XML database. Default is localhost.
port: The port of the XML database. Default is 1984 (BaseX default).
user: The name of the user that connects with the database. Default is admin (BaseX default).
password: The corresponding password. Default is admin (BaseX default).
src/main/resources/environment.properties

The environment.properties file stores the name of the MBAse and collections therein and sets the interval for update checking. The file has the following properties:

database: The name of the MBA database the collections of which are observed by the environment and checked for updates.
collections: A comma-separated list of names of collections in the MBAse as defined by the database property.
repeatFrequency: The length of the interval in seconds between checks for updates and execution of transitions. Default is 15 (seconds).
src/main/resources/quartz.properties

Normally, these properties shouldn't be changed at all. Proceed with caution!

src/main/resources/log4j.properties

Use this to tweak log4j output. If you want to store logs in a separate file, this is the point to configure it.

Startup

The main class is at.jku.dke.mba.environment.Environment, which must be started in order to get the multilevel business process environment running.

The multilevel process environment checks, in a configurable interval, which MBAs in the MBA database have been altered and calls the execution engine. The execution engine resolves any actions that need to be taken and updates the MBA accordingly.

Examples

The src/test directory contains multiple JUnit test suites and example XML files.
(Own example an Examples taken from SCXML 1.0 Implementation Report [3]


References

[1] Christoph Schütz, Lois M. L. Delcambre and Michael Schrefl: Multilevel Business Artifacts. http://link.springer.com/chapter/10.1007%2F978-3-642-36285-9_35

[2] Christoph Schütz and Michael Schrefl: Variability in Artifact-Centric Process Modeling: The Hetero-Homogeneous Approach. http://crpit.com/confpapers/CRPITV154Schutz.pdf

[3]  SCXML - IRP https://www.w3.org/Voice/2013/scxml-irp/

[4] https://github.com/xtoph85/MultilevelProcessEnvironment

[5] https://github.com/xtoph85/MBAse

[6] https://github.com/xtoph85/SCXML-XQ

