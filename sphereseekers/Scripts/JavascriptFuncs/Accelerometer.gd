extends Node

func create_accelerometer():
	if not OS.has_feature('web'): pass
	JavaScriptBridge.eval("""
		var acceleration = { x: 0, y: 0, z: 0 }

		function registerMotionListener() {
			window.ondevicemotion = function(event) {
				if (event.acceleration.x === null) return
				acceleration.x = event.acceleration.x
				acceleration.y = event.acceleration.y
				acceleration.z = event.acceleration.z
			}
		}
		
		let gyro = new Gyroscope();
		var gyro_data = {x: 0, y: 0, z: 0};
		gyro.start();
		
		gyro.onreading = () => {
			gyro_data.x = gyro.x;
			gyro_data.y = gyro.y;
			gyro_data.z = gyro.z;
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
	return Vector3(x, y, z)
	
