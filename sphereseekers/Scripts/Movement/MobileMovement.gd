extends Node

var is_initialized = false

func create_listeners():
	if not OS.has_feature('web'):
		return
	# Set up initial values and listeners
	JavaScriptBridge.eval("""
		window.gyro_data = { 
			alpha: 0,  // rotation around z-axis (compass direction)
			beta: 0,   // rotation around x-axis (front-to-back tilt)
			gamma: 0,  // rotation around y-axis (left-to-right tilt)
			rotationRate: { alpha: 0, beta: 0, gamma: 0 }  // actual gyroscope data
		};
		window.sensor_permission = "pending";
		
		function registerMotionListener() {
			// Device orientation for orientation data
			window.ondeviceorientation = function(event) {
				window.gyro_data.alpha = event.alpha || 0;
				window.gyro_data.beta = event.beta || 0;
				window.gyro_data.gamma = event.gamma || 0;
			};
			
			// Device motion for rotationRate (actual gyroscope data)
			window.ondevicemotion = function(event) {
				if (event.rotationRate) {
					window.gyro_data.rotationRate.alpha = event.rotationRate.alpha || 0;
					window.gyro_data.rotationRate.beta = event.rotationRate.beta || 0;
					window.gyro_data.rotationRate.gamma = event.rotationRate.gamma || 0;
				}
			};
		}
	""", true)
	is_initialized = true

func request_permission():
	if not OS.has_feature('web') or not is_initialized:
		return false
	JavaScriptBridge.eval("""
		if (typeof DeviceOrientationEvent !== 'undefined' && typeof DeviceOrientationEvent.requestPermission === 'function') {
			// iOS 13+ requires permission
			DeviceOrientationEvent.requestPermission()
			.then(function(response) {
				if (response === 'granted') {
					registerMotionListener();
					window.sensor_permission = "granted";
					console.log("Motion permission granted");
				} else {
					window.sensor_permission = "denied";
					console.log("Motion permission denied");
				}
			})
			.catch(function(error) {
				window.sensor_permission = "error";
				console.log("Motion permission error:", error);
			});
		} else {
			// Non-iOS devices
			registerMotionListener();
			window.sensor_permission = "granted";
			console.log("Motion permission auto-granted (non-iOS)");
		}
	""", true)
	return true

func get_tilt() -> Dictionary:
	if not OS.has_feature('web') or not is_initialized:
		return {"alpha": 0, "beta": 0, "gamma": 0, "rotationRate": {"alpha": 0, "beta": 0, "gamma": 0}}
	
	var alpha = JavaScriptBridge.eval('window.gyro_data.alpha || 0')
	var beta = JavaScriptBridge.eval('window.gyro_data.beta || 0')
	var gamma = JavaScriptBridge.eval('window.gyro_data.gamma || 0')
	
	var rot_alpha = JavaScriptBridge.eval('window.gyro_data.rotationRate.alpha || 0')
	var rot_beta = JavaScriptBridge.eval('window.gyro_data.rotationRate.beta || 0')
	var rot_gamma = JavaScriptBridge.eval('window.gyro_data.rotationRate.gamma || 0')
	
	return {
		"alpha": alpha, 
		"beta": beta, 
		"gamma": gamma,
		"rotationRate": {
			"alpha": rot_alpha, 
			"beta": rot_beta, 
			"gamma": rot_gamma
		}
	}

func get_permission_status() -> String:
	if not OS.has_feature('web'):
		return "unsupported"
	if not is_initialized:
		return "not_initialized"
	var status = JavaScriptBridge.eval('window.sensor_permission')
	return str(status)
