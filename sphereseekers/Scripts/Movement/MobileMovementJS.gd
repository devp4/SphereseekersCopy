extends Node

func create_listeners():
	if not OS.has_feature('web'): pass
	JavaScriptBridge.eval("""
		var gyro_data = {beta: 0, gamma: 0};

		function registerMotionListener() {
			window.ondeviceorientation = function(event) {
				gyro_data.beta = event.beta || 0;
				gyro_data.gamma = event.gamma || 0;
			}
		}
		
		if (typeof DeviceOrientationEvent.requestPermission === 'function') {
			DeviceOrientationEvent.requestPermission().then(function(state) {
				if (state === 'granted') registerMotionListener()
			})
		}
		else {
			registerMotionListener()
		}
	""", true)

func get_tilt():
	if not OS.has_feature('web'): return null
	
	var beta = JavaScriptBridge.eval('gyro_data.beta')
	var gamma = JavaScriptBridge.eval('gyro_data.gamma')

	return {"beta": beta, "gamma": gamma}
	
