#!/bin/bash

set -o nounset # exit script if trying to use an uninitialized variable
<<comment
set -o errexit # exit the script if any statement returns a non-true return value
comment
set -x
main() {
    echo "Starting lookup.."
    echo "Checking jq tool dependency.."
    echo "$@"
    check_tool_dependency    
    FILE=data.json
    if [ -f "$FILE" ]
    then
        echo "file exists, deleting and updating the latest dataset."
        $(rm -f $FILE)
        echo "Downloading reference data from https://www.travel-advisory.info/api"
        $(curl -# -S https://www.travel-advisory.info/api > $FILE)
        echo "Download dataset Completed"
    else
        echo "Downloading reference data from https://www.travel-advisory.info/api"
        $(curl -# -S https://www.travel-advisory.info/api > $FILE)
	echo "Download dataset completed"
    fi
    if [ "$#" -eq 0 -a "$#" -ge 2 ]
    then
        show_help
    else
        echo "$*" > plcaeholder 
        local key=$(cat plcaeholder | cut -d '=' -f1)
        local values=$(cat plcaeholder | cut -d '=' -f2)
	    echo "Values: $values"
        `rm -f placeholder`
        if [[ "$key" == "--countryCodes" && "$values" != " " ]]
        then
            IFS=","
            for value in $values
            do
	            local countryName=$(cat $FILE | jq ".data.${value}.name")
                : ' 
                        echo "---$?---"
		                echo "Country Name = $countryName"
                '
		        if [[ "$?" -eq 0 && "$countryName" != "null" && "$countryName" != "" ]]
		        then
			        echo "For Country Code $value: $countryName"
                    echo "Done lookup.." 
		        else 
                    echo "Enter Valid Country Code.."
			        show_help
			        exit 1002
                fi
            done
        else
                show_help
     	        exit 1003
        fi
    fi

}

show_help() {
  cat <<EOM
  Mandatory:
  OPTIONS:
  Usage: $(basename "$0") --countryCodes <countryCodes seperated by ','>
  For Single Country lookup..
  E.g.: lookup --countryCodes=AU
  OR
  For Multiple Country lookup..
  E.g.: lookup --countryCodes=AU,IN
EOM
}

check_tool_dependency() {

#    `lsb_release -a | grep -i ubuntu`
     local localvalue=`uname -a | grep -i ubuntu`
                if [ "$?" -eq 0 ]
                then
                    local qresult=$(dpkg-query -l 'jq')
                    if [ "$?" -eq 0 ]
                    then
                        echo "needed tool jq is installed, good to go.. "
                    else
                        echo "Installing jq.."
			local update=`apt-get update -y`
                        local jq=`apt-get install jq -y`
                        echo "jq installed"
                    fi
                else
                    echo "platform is not supported..please install jq manually.."
                    exit 1001
                fi

}

main "$@"
