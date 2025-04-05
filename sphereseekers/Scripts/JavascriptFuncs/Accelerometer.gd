extends Node

func create_accelerometer():
	if not OS.has_feature('web'): pass
	JavaScriptBridge.eval("""
		var acceleration = { x: 0, y: 0, z: 0 };
		var gyro_data = {x: 0, y: 0, z: 0, beta: 0, gamma: 0};

		function registerMotionListener() {
			window.ondevicemotion = function(event) {
				if (event.acceleration.x === null) return
				acceleration.x = event.acceleration.x
				acceleration.y = event.acceleration.y
				acceleration.z = event.acceleration.z
			}
			
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

func get_acceleration():
	if not OS.has_feature('web'): return null
	
	var x = JavaScriptBridge.eval('acceleration.x')
	var y = JavaScriptBridge.eval('acceleration.y')
	var z = JavaScriptBridge.eval('acceleration.z')
	return Vector3(x, y, z)

func get_gyro():
	if not OS.has_feature('web'): return null
	
	var x = JavaScriptBridge.eval('gyro_data.x')
	var y = JavaScriptBridge.eval('gyro_data.y')
	var z = JavaScriptBridge.eval('gyro_data.z')
	var beta = JavaScriptBridge.eval('gyro_data.beta')
	var gamma = JavaScriptBridge.eval('gyro_data.gamma')

	return {"beta": beta, "gamma": gamma}
	
