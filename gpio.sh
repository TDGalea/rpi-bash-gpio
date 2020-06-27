#!/bin/bash

####################################################################################################################
# Raspberry Pi GPIO interface script by Thomas Galea.                                                              #
# Version 1.0                                                                                                      #
#                                                                                                                  #
# Feel free to use this script however you want. Take it, use it, modify it, improve it, learn from it.            #
# I simply ask that you keep my name in here if you plan to further share it!                                      #
#                                                                                                                  #
# If you find any problems with this script, please let me know! I'll try to solve any issues as soon as possible. #
####################################################################################################################

# Ensure this is a Raspberry Pi.
# This may not be a perfect method to check this:
# If the Raspberry Pi Foundation ever changes the Model string in /proc/cpuinfo, this check may fail.
# Please inform me if this is the case, or you have a better alternative to this.
if [ "$(cat /proc/cpuinfo | grep 'Raspberry Pi')" = "" ];then
	echo "This system is not a Raspberry Pi!"
	echo "If you're using another board that you believe this script should work with, please let me know, and I'll modify the script to allow for your board."
	exit 1
fi

gpio="/sys/class/gpio"
# This string gives me nightmares. Colourisation is fun.
helpCmdList="	\e[1;37m$0\e[0m [\e[1;32mlist\e[0m/\e[1;32mexport\e[0m/\e[1;32munexport\e[0m/\e[1;32medge\e[0m/\e[1;32minv\e[0m/\e[1;32mdir\e[0m/\e[1;32mset\e[0m/\e[1;32mget\e[0m] [\e[1;33mGPIO#\e[0m] [\e[1;36mvalue\e[0m]"

# Show basic help if parameter 1 is blank.
if [ "$1" = "" ];then
	echo "Raspberry Pi GPIO interface script by Thomas Galea."
	echo "Usage:"
	echo -e "$helpCmdList"
	echo
	echo "Use '$0 help' for more usage information."
	exit 0
fi

# Display basic help if parameter 1 doesn't match one from the below case list.
invalid=1
case $1 in
	    help) invalid=0;;
	    list) invalid=0;;
	  export) invalid=0;;
	unexport) invalid=0;;
	    edge) invalid=0;;
	     inv) invalid=0;;
	     dir) invalid=0;;
	     set) invalid=0;;
	     get) invalid=0;;
esac
if [ "$invalid" = "1" ];then
	echo "Invalid command."
	echo "Use '$0 help' for more usage information."
	exit 2
fi

# Help
if [ "$1" = "help" ];then
	function displayHelp {
		echo "Raspberry Pi GPIO interface script by Thomas Galea."
		echo "Usage:"
		echo -e "$helpCmdList"
		echo
		echo -e "	\e[1;32mlist\e[0m		Lists the currently enabled GPIO pins."
		echo -e "			\e[1;37m$0\e[0m \e[1;32mlist\e[0m"
		echo
		echo -e "	\e[1;32mexport\e[0m		Enables a GPIO pin for use."
		echo -e "			\e[1;37m$0\e[0m \e[1;32mexport \e[1;33m21\e[0m"
		echo
		echo -e "	\e[1;32munexport\e[0m	Disables a GPIO pin, preventing use."
		echo -e "			\e[1;37m$0\e[0m \e[1;32munexport \e[1;33m21\e[0m"
		echo
		echo -e "	\e[1;32medge\e[0m		Sets a GPIO pin's edge. Valid options are 'none', 'rising', 'falling', or 'both'."
		echo -e "			\e[1;37m$0\e[0m \e[1;32medge \e[1;33m21 \e[1;36mnone\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32medge \e[1;33m21 \e[1;36mrising\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32medge \e[1;33m21 \e[1;36mfalling\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32medge \e[1;33m21 \e[1;36mboth\e[0m"
		echo
		echo -e "	\e[1;32minv\e[0m		Sets a GPIO pin's 'active_low' value. If this is 1, the pin's value is essentially inverted."
		echo -e "			\e[1;37m$0\e[0m \e[1;32minv \e[1;33m21 \e[1;36m0\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32minv \e[1;33m21 \e[1;36m1\e[0m"
		echo
		echo -e "	\e[1;32mdir\e[0m		Sets a GPIO pin's direction as either input or output."
		echo -e "			\e[1;37m$0\e[0m \e[1;32mdir \e[1;33m21 \e[1;36min\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32mdir \e[1;33m21 \e[1;36mout\e[0m"
		echo
		echo -e "	\e[1;32mset\e[0m		Sets the value of a GPIO pin either high (1) or low (0)."
		echo -e "			\e[1;37m$0\e[0m \e[1;32mset \e[1;33m21 \e[1;36m0\e[0m"
		echo -e "			\e[1;37m$0\e[0m \e[1;32mset \e[1;33m21 \e[1;36m1\e[0m"
		echo
		echo -e "	\e[1;32mget\e[0m		Displays the current value of a GPIO pin."
		echo -e "			\e[1;37m$0\e[0m \e[1;32mget \e[1;33m21\e[0m"
		echo
	}
	displayHelp | more
	exit 0
fi

# List
if [ "$1" = "list" ];then
	function listPins {
		for pin in $gpio/gpio*;do
			# Ensure this file isn't a GPIO chip.
			if [ "$(echo $pin | grep chip)" = "" ];then
				if [ "$(cat $pin/active_low)" = "0" ];then
					invert="No"
				else
					invert="Yes"
				fi
				echo "       Pin: ${pin:20:2}"
				echo " Direction: $(cat $pin/direction)"
				echo "      Edge: $(cat $pin/edge)"
				echo "  Inverted: $invert"
				echo "     Value: $(cat $pin/value)"
				echo ""
			fi
		done
	}
	listPins | more
	exit 0
fi

# Export
if [ "$1" = "export" ];then
	# Ensure parameter 2 is present.
1	if [ "$2" = "" ];then
		echo "Export what GPIO pin?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Export pin.
		echo "$2" > $gpio/export;err=$?
		# Check if success. If not, report.
		if [ "$err" = "0" ];then
			echo "Success."
			exit 0
		else
			echo "Failed to export pin. Ensure you've entered the command correctly, and that you have the required permissions."
			exit $err
		fi
	fi
fi

# Unexport
if [ "$1" = "unexport" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "Unexport what GPIO pin?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Unexport pin.
		echo "$2" > $gpio/unexport;err=$?
		# Check if success. If not, report.
		if [ "$err" = "0" ];then
			echo "Success."
			exit 0
		else
			echo "Failed to unexport pin. Ensure you've entered the command correctly, and that you have the required permissions."
			exit $err
		fi
	fi
fi

# Edge
if [ "$1" = "edge" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "What GPIO pin do you want to change?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Ensure parameter 3 is present.
		if [ "$3" = "" ];then
			echo "What egde should this pin be?"
			echo "(Use '$0 help' for full command usage help)."
			exit 2
		else
			# Ensure that GPIO pin is exported.
			if [ ! -d "$gpio/gpio$2" ];then
				echo "That pin is not exported. Please export it first."
				exit 1
			else
				# Check if parameter 3 is a valid edge input.
				validEdge=0
				case $3 in
					   none) validEdge=1;;
					 rising) validEdge=1;;
					falling) validEdge=1;;
					   both) validEdge=1;;
				esac
				if [ "$validEdge" = "0" ];then
					echo "'$3' is not a valid egde."
					echo "(Use '$0 help' for full command usage help)."
					exit 1
				else
					# Set pin egde.
					echo "$3" >$gpio/gpio$2/edge;err=$?
					# Check if success. Report if not.
					if [ "$err" = "0" ];then
						echo "Success."
						exit 0
					else
						echo "Failed to set pin edge. Please ensure you have the required permissions."
						exit $err
					fi
				fi
			fi
		fi
	fi
fi

# Invert
if [ "$1" = "inv" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "What GPIO pin do you want to change?"
		echo "(use '$0 help' for full command usage help)."
		exit 2
	else
		# Ensure parameter 3 is present.
		if [ "$3" = "" ];then
			echo "Should this pin be inverted or not?"
			echo "(use '$0 help' for full command usage help)."
			exit 2
		else
			# Ensure that GPIO pin is exported.
			if [ ! -d "$gpio/gpio$2" ];then
				echo "That pin is not exported. Please export it first."
				exit 1
			else
				# Set pin active_low value.
				echo "$3" >$gpio/gpio$2/active_low;err=$?
				# Check if success. If not, report.
				if [ "$err" = "0" ];then
					echo "Success."
					exit 0
				else
					echo "Failed to modify pin. Please ensure you have the required permissions."
					exit $err
				fi
			fi
		fi
	fi
fi


# Direction
if [ "$1" = "dir" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "What GPIO pin do you want to change?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Ensure parameter 3 is present.
		if [ "$3" = "" ];then
			echo "What direction should this pin be?"
			echo "(Use '$0 help' for full command usage help)."
			exit 2
		else
			# Ensure that GPIO pin is exported.
			if [ ! -d "$gpio/gpio$2" ];then
				echo "That pin is not exported. Please export it first."
				exit 1
			else
				# Ensure parameter 3 is a valid direction.
				validDir=0
				case $3 in
					 in) validDir=1;;
					out) validDir=1;;
				esac
				if [ "$validDir" = "0" ];then
					echo "'$3' is not a valid direction."
					echo "(Use '$0 help' for full command usage help)."
					exit 1
				else
					# Set pin direction.
					echo "$3" > $gpio/gpio$2/direction;err=$?
					# Check if success. If not, report.
					if [ "$err" = "0" ];then
						echo "Success."
						exit 0
					else
						echo "Failed to set pin direction. Please ensure you have the required permissions."
						exit $err
					fi
				fi
			fi
		fi
	fi
fi

# Set Value
if [ "$1" = "set" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "Set what pin?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Ensure parameter 3 is present.
		 if [ "$3" = "" ];then
		 	echo "Set to what value?"
			echo "(Use '$0 help' for full command usage help)."
			exit 2
		else
			# Ensure that GPIO pin is exported.
			if [ ! -d "$gpio/gpio$2" ];then
				echo "That pin is not exported. Please export it first."
				exit 1
			else
				# Ensure that GPIO pin is set as OUTPUT.
				if [ "$(cat $gpio/gpio$2/direction)" != "out" ];then
					echo "That pin is not set to be an output. You cannot modify the value of input pins from here."
					echo "If you absolutely must modify the value from here, use the 'inv' command instead."
					echo "(Use '$0 help' for full command usage help)."
					exit 1
				else
					# Set pin value.
					echo "$3" > /sys/class/gpio/gpio$2/value;err=$?
					# Check if success. If not, report.
 					if [ "$err" = "0" ];then
 						echo "Success."
 						exit 0
 					else
 						echo "Failed to set pin value. Please ensure you have the required permissions."
 						exit $err
					fi
				fi
			fi
		fi
	fi
fi

# Get Value
if [ "$1" = "get" ];then
	# Ensure parameter 2 is present.
	if [ "$2" = "" ];then
		echo "Get what pin?"
		echo "(Use '$0 help' for full command usage help)."
		exit 2
	else
		# Ensure that GPIO pin is exported.
		if [ ! -d "$gpio/gpio$2" ];then
			echo "That pin is not exported."
			exit 0
		else
			# Get pin value.
			cat /sys/class/gpio/gpio$2/value;err=$?
			exit $err
		fi
	fi
fi

# The script should exit before this point.
echo "Script reached end of file. This shouldn't be possible, so please inform me!"
exit 255
