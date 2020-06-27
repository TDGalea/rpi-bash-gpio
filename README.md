Raspberry Pi GPIO interface script by Thomas Galea.

Feel free to use this script however you want. Take it, use it, modify it, improve it, learn from it.
I simply ask that you keep my name in here if you plan to further share it!

If you find any problems with this script, please let me know! I'll try to solve any issues as soon as possible.

	Usage:
	gpio [list/export/unexport/edge/inv/dir/set/get] [GPIO#] [value]

	list		Lists the currently enabled GPIO pins.
				/exec/gpio list

	export		Enables a GPIO pin for use.
				/exec/gpio export 21

	unexport	Disables a GPIO pin, preventing use.
				/exec/gpio unexport 21

	edge		Sets a GPIO pin's edge. Valid options are 'none', 'rising', 'falling', or 'both'.
				/exec/gpio edge 21 none
				/exec/gpio edge 21 rising
				/exec/gpio edge 21 falling
				/exec/gpio edge 21 both

	inv		Sets a GPIO pin's 'active_low' value. If this is 1, the pin's value is essentially inverted.
				/exec/gpio inv 21 0
				/exec/gpio inv 21 1

	dir		Sets a GPIO pin's direction as either input or output.
				/exec/gpio dir 21 in
				/exec/gpio dir 21 out

	set		Sets the value of a GPIO pin either high (1) or low (0).
				/exec/gpio set 21 0
				/exec/gpio set 21 1

	get		Displays the current value of a GPIO pin.
				/exec/gpio get 21
