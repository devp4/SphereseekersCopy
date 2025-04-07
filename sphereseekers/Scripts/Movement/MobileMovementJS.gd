extends Node

var is_initialized = false

func create_listeners():
	if not OS.has_feature('web'):
		return
	
	# Set up initial values
	JavaScriptBridge.eval("""
		window.gyro_data = { beta: 0, gamma: 0 };
		window.sensor_permission = "pending";
		
		function registerMotionListener() {
			window.ondevicemotion = function(event) {
				if (event.accelerationIncludingGravity) {
					window.acceleration.x = event.accelerationIncludingGravity.x;
					window.acceleration.y = event.accelerationIncludingGravity.y;
					window.acceleration.z = event.accelerationIncludingGravity.z;
				}
			};
			window.ondeviceorientation = function(event) {
				window.gyro_data.beta = event.beta || 0;
				window.gyro_data.gamma = event.gamma || 0;
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
		return {"beta": 0, "gamma": 0}
	var beta = JavaScriptBridge.eval('window.gyro_data.beta || 0')
	var gamma = JavaScriptBridge.eval('window.gyro_data.gamma || 0')
	return {"beta": beta, "gamma": gamma}

func get_permission_status() -> String:
	if not OS.has_feature('web'):
		return "unsupported"
	if not is_initialized:
		return "not_initialized"
	var status = JavaScriptBridge.eval('window.sensor_permission')
	return str(status)
