
# FFR-Resistance Driver -

This project focused on creating a software to drive the motor and valve to create resistance in the 3D printed model.
The program keeps track of three basic things:
1. Monitoring flow rates
1. Sending data to database and visualization system
1. Directing motor and valve when to fire and for how long.  

The flow rate data is inputted to the Raspberry Pi through SPI code.  Since the system is developed for multiple flow rate sensors,
the code threads the collection of flow rate sensor data.  The data is then indexed and stored in Elasticsearch,
with the parameters of time, sensor number and flowrate.  The data can then be displayed through Kibana and visualized
in real time as the experiment progresses.  To run the program first install set up Elasticsearch and Kibana on your personal laptop by the steps below.

The motor and valves are controlled through the [Pi_piper](https://github.com/jwhitehorn/pi_piper) library. The calibration is used to match the
systole and diastole transition rates of the pump.  This would allow a scheduler mode so that the motors turn on and create resistance during
systole, in time with the pump.  New suggestion: Don't use the pump. Ask Lauren.

## ElasticSearch and Kibana (on personal laptop)
### Setup (I did this in windows but it probably is better in your VM -- would have different commands)
  1.  Download and install [Java 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
  1. Download [Elasticsearch](https://www.elastic.co/downloads/elasticsearch) and install as shown
  1. Download and unzip [Kibana](https://www.elastic.co/downloads/past-releases/kibana-5-2-2)

-Using Windows
  1. Open Command Prompt as administrator
  1. Navigate to the bin directory in unziped files (using cd)
  1. Run Command
      ```
      .\elasticsearch.bat -Enetwork.host=0.0.0.0
      ```
  1. Find address that elasticsearch is listening on
      ```
      Example
      [qGNPGBO] publish_address {192.168.1.10:9200}, bound_addresses {[::]:9200}
      ```
  1. Go inside Kibana folder and find config directory `kibana.yml`
  1. Change URL to given elasticsearch host and port
      ```
      Example
      elasticsearch.url: "http://192.168.1.10:9200"
      ```
  1. Open second command prompt as administrator
  1. Navigate to the unziped bin directory of kibana
  1. Run:
      ```
      .\kibana.bat
      ```
  1. Go to webbrowser and hit
      ```
      http://localhost:5601
      ```
      You should see the loading page for Kibana

## How to run script on Pi
1. Turn on Pi with mouse and keyboard attached
1. Open the terminal type in:
```
bash -l
```
then
```
 rvm use test-project@ruby-2.4.0
 ```
This initializes the bash shell and switch to the proper gemset.

1. Sign on to Wifi (try to get UB secure otherwise use Kalidea)
  - If using Kalidea you have to authorize use of their public Wi-FI
1. cd into ffr folder using your linux skills
1. Run file using (when you are initializing elasticsearch):
```
rvmsudo ./program.rb "http://192.168.1.10:9200"
```
1. Run file using (when no elasticsearch necessary):
```
rvmsudo ./program.rb
```

## Documents
  - Below is a list of the remaining code documents and their use case:  
    1. motortest.rb - Use to easily turn on and off motor and valve.
    1. sensor_motor_program.rb - Data is sent to elasticsearch and user inputs time that motors are on
    1. mediancalibration.rb- used to calibrate with pump (count is too high) but doesn't working
    1. driver.rb- eventually allows a website to connect between the raspberry pi and kibana so don't have to include IP address in run command
        - Eventually can attach final driver script to driver.rb (where fork command is), open https://localhost:4567 on Pi.  Allows you to add the laptop IP address and start and stop the experiment through the Pi
