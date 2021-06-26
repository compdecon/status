#!/bin/bash

# Update the json
# push it to github

# What is dynamic
# location.timezone
# location.localtime
# lots of sensors (but not at this time)
#   0 = Front Gate
#     sensors.door_locks.[0].value = false
#   1 = Front Door
#     sensors.door_locks.[1].value = false
# Get weather forecast for KBLM
# curl https://api.weather.gov/gridpoints/PHI/83,90/forecast | jq '.properties.periods[0]'
# weather
#

# ------------------------------------------------------------------------------
# Problem: If I put this in a cronjob it will default to closed. So how do I run
#          a cron and have it correctly set the status.json?
# Answer:  ???
# ------------------------------------------------------------------------------
# getops
while getopts ":c:hx:t:" opt; do
    case ${opt} in
        c ) # CDL (Podcast Studio)
            target=$OPTARG
            # 1 = open
            # 0 = closed
            ;;

        x ) # IXR (Makerspace)
            target=$OPTARG
            # 1 = open
            # 0 = closed
            ;;

        h ) # process option h
            # 1 = open
            # 0 = closed
            ;;

        t ) # process option t
            target=$OPTARG
            # 1 = open
            # 0 = closed
            ;;

        \? )
            echo "Usage: cmd [-h] [-t]"
            ;;
    esac
done
shift $((OPTIND -1))
# ------------------------------------------------------------------------------

if [ -n ${OPEN} ]; then
    # 
    STATE="open"
    LSTATE="true"
    DOOR_LOCK="true"
    GATE_LOCK="true"
    # Occupancy
    OLAB=1
    OCLASS=0
    OSTUDIO=0
    OVSPACE=-1
else
    # 
    STATE="closed"
    LSTATE="false"
    DOOR_LOCK="false"
    GATE_LOCK="false"
    # Occupancy
    OLAB=0
    OCLASS=0
    OSTUDIO=0
    OVSPACE=-1
fi

MSG="All visitors to the makerspace are required to mask as per the State of New Jersey requirements and maintain appropriate social distancing while in the building"
MSG="Experimenting with SpaceAPI"

# Humidity
HLAB="60.0"
HCLASS="60.0"
HSTUDIO="60.0"
HOUTSIDE="-1.0"

# Network Connections
CONNS=0

# Temperature
#UNIT="\u00b0C"
TUNIT="\u00b0F"
#UNIT="\u00b0K"
TLAB=70
TCLASS=70
TSTUDIO=70
TOUTSIDE=-1

#
# Probably need this to be in another cron that runs 4 times a day (every 6 hours)
#EATHER=$(curl https://api.weather.gov/gridpoints/PHI/83,90/forecast | jq '.properties.periods[0]')
WEATHER=$(cat /tmp/forecast)
#
JSON="{
  \"api_compatability\": [\"14\"],
  \"api\": \"0.13\",
  \"version\": \"0.0.1 alpha\",
  \"comment\": \"API is a work in progress\",
  \"space\": \"CDL - Computer Deconstruction Lab\",
  \"logo\": \"http://compdecon.org/wp-content/uploads/2018/10/cdl_white_large.png\",
  \"logo\": \"https://compdecon.github.io/images/CDL-Logo-black.png\",
  \"url\": \"https://compdecon.github.io/\",
  \"location\": {
      \"address\": \"Computer Deconstruction Lab, Building 9059, 2201 Marconi Road, Wall Township, N.J. 07719, USA\",
      \"lat\": -74.06020538859792,
      \"long\": 40.186497308776936,
      \"timezone\": \"$(date '+%Y/%m/%d %H:%M:%S %Z UTC%:z')\",
      \"localtime\": \"$(date)\",
      \"comment\": \"date '+%Y/%m/%d %H:%M:%S %Z UTC%:z'# EDT/GMT+4 EST/GMT+5\"
  },
  \"sensors\": {
      \"comment\": \"optional\",
      \"door_locked\": [
          {
              \"location\": \"Front gate\",
              \"value\": ${GATE_LOCK}
          }, {
              \"location\": \"Front door\",
              \"value\": ${DOOR_LOCK}
          }
      ],
      \"humidity\": [
          {
              \"location\": \"Lab\",
              \"unit\": \"%\",
              \"value\": ${HLAB}
          }, {
              \"location\": \"Studio\",
              \"unit\": \"%\",
              \"value\": ${HSTUDIO}
          }, {
              \"location\": \"Classroom\",
              \"unit\": \"%\",
              \"value\": ${HCLASS}
          }, {
              \"location\": \"Outside\",
              \"unit\": \"%\",
              \"value\": ${HOUTSIDE}
          }
      ],
      \"network_connections\": [
          {
              \"value\": ${CONNS}
          }
      ],
      \"occupancy\": [
          {
              \"location\": \"Lab\",
              \"value\": ${OLAB}
          }, {
              \"location\": \"Classroom\",
              \"value\": ${OCLASS}
          }, {
              \"location\": \"Studio\",
              \"value\": ${OSTUDIO}
          }, {
              \"location\": \"vspace\",
              \"value\": ${OVSPACE}
          }
      ],
      \"temperature\": [
          {
              \"location\": \"Lab\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TLAB}
          }, {
              \"location\": \"Classroom\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TCLASS}
          }, {
              \"location\": \"Studio\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TSTUDIO}
          }, {
              \"location\": \"Outside\",
              \"unit\": \"${TUNIT}\",
              \"value\": ${TOUTSIDE}
          }
      ]
  },
  \"weather\": ${WEATHER},
  \"contact\": {
    \"email\": \"info@compdecon.org\",
    \"phone\": \"+1-732-456-5001\",
    \"meetup\": \"\",
    \"irc\": \"\",
    \"ml\": \"cdl@groups.io\",
    \"identica\": \"\",
    \"twitter\": \"@compdecon\",
    \"facebook\": \"https://www.facebook.com/groups/compdecon\"
  },
  \"issue_report_channels\": [
    \"email\"
  ],
  \"feeds\": {
      \"blog\":{
          \"type\": \"application/rss+xml\",
          \"url\":\"http://compdecon.org/feed/\"
      }
  },
  \"links\": [
      {\"name\": \"SpaceAPI\", \"description\":\"spaceapi.io docs\",\"url\":\"https://spaceapi.io/docs/\"},
      {}
  ],
  \"state\": {
      \"open\": ${LSTATE},
      \"lastchange\": $(date +%s),
      \"message\": \"${MSG}.\",
      \"icon\": {
          \"open\": \"https://compdecon.github.io/images/open.png\",
          \"closed\": \"https://compdecon.github.io/images/closed.png\"
      },
      \"mqtt\": {
          \"host\": \"example.org\",
          \"closed\": \"closed\",
          \"tls\": true,
          \"topic\": \"compdecon/state\",
          \"port\": 1883,
          \"open\": \"open\"
    }
  },
  \"cam\": [
  ],
  \"events\": [
      {
          \"name\": \"N/A\",
          \"type\": \"\",
          \"timestamp\": -1,
          \"extra\": \"\"
      }, {
      }
  ],
  \"projects\": [
  ],
  \"space\": \"CDL - Computer Deconstruction Lab\",
  \"spacefed\": {
      \"spacephone\": false,
      \"spacesaml\": false,
      \"spacenet\": false
  }
}"

echo ${JSON} > status.json
