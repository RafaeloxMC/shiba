extends Node

var is_init: bool = false
const API_BASE: String = "https://shibadb.xvcf.dev/api/v1"
var api_key: String = ""
var req
var logged_in = false

signal api_response(res, code, headers, body)
signal save_loaded(saveData)
	
func init_shibadb(key: String):
	if is_init:
		print("WARNING: ShibaDB should not be initialized more than once!")
		return
	api_key = key
	req = HTTPRequest.new()
	req.request_completed.connect(self.handle_res)
	
	add_child(req)
	
	var js_payload = """
	fetch('%s', {
	    method: 'GET',
	    credentials: 'include'
	})
	.then(res => res.text())
	.then(text => console.log('Auth check:', text))
	""" % [API_BASE + "/auth/me"]

	JavaScriptBridge.eval(js_payload, true)
	api_response.connect(is_data_save)
	print("ShibaDB initialized!")
	is_init = true
	
func save_progress(values: Dictionary[String, Variant]) -> void:
	if OS.get_name() != "Web":
		print("Dynamically saving progress is not supported on this platform!")
		return
	
	var payload = "{\"saveData\": " + JSON.stringify(values) + "}"
	print(payload)
	
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	
	var callback_name = "godot_shibadb_callback_save_" + str(Time.get_ticks_msec())
	
	var js_setup = "window." + callback_name + " = null;"
	JavaScriptBridge.eval(js_setup, true)
	
	var window = JavaScriptBridge.get_interface("window")
	window[callback_name] = callback
	
	var js_payload = """
	fetch('%s', {
		method: 'POST',
		credentials: 'include',
		headers: {
			'Content-Type': 'application/json'
		},
		body: '%s'
	})
	.then(function(response) {
		var headers = "";
		response.headers.forEach(function(value, key) {
			headers += key + ":" + value + "\\n"
		});
		return [response.status, headers, response]
	})
	.then(function([status, headers_str, response]) {
		if (!response.ok) {
			throw new Error("HTTP " + status) 
		}
		
		return response.text().then(function(text) {
			window.%s([0, status, headers_str, text])
		})
	})
	.catch(function(error) {
		window.%s([1, 0, "", "Error: " + error.message])
	})
	""" % [API_BASE + "/games/" + api_key + "/data", payload, callback_name, callback_name]
	
	JavaScriptBridge.eval(js_payload, true)

# WARNING: THIS SHOULD ONLY EVER BE USED IN DEVELOPMENT! DO NOT PUSH THIS TO PRODUCTION!!! THIS WILL LEAK YOUR SHIBADB TOKEN! USE DYNAMIC LOADING INSTEAD!
func save_progress_with_cookie(values: Dictionary[String, Variant], cookie: String) -> void:
	var payload = JSON.stringify(values, "\t")
	
	var err = req.request(API_BASE + "/games/" + api_key + "/data", ["Cookie: shibaCookie=" + cookie], HTTPClient.METHOD_POST, "{\"saveData\":" + payload + "}")
	if err != OK:
		print("Something went wrong while requesting ShibaDB!\n" + str(err))

func load_progress():
	if OS.get_name() != "Web":
		print("Dynamically loading progress is not supported on this platform!")
		return
	
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	
	var callback_name = "godot_shibadb_callback_load_" + str(Time.get_ticks_msec())
	
	var window = JavaScriptBridge.get_interface("window")
	window[callback_name] = callback
	
	var js_payload = """
	(function() {
		fetch('%s', {
			method: 'GET',
			credentials: 'include'
		})
		.then(function(response) {
			var headers = "";
			response.headers.forEach(function(value, key) {
				headers += key + ":" + value + "\\n"
			});
			return [response.status, headers, response]
		})
		.then(function([status, headers_str, response]) {
			if (!response.ok) {
				throw new Error("HTTP " + status) 
			}
			
			return response.text().then(function(text) {
				if (window.%s && typeof window.%s === 'function') {
					window.%s([0, status, headers_str, text])
				}
			})
		})
		.catch(function(error) {
			if (window.%s && typeof window.%s === 'function') {
				window.%s([1, 0, "", "Error: " + error.message])
			}
		})
	})();
	""" % [
		API_BASE + "/games/" + api_key + "/data",
		callback_name, callback_name, callback_name,
		callback_name, callback_name, callback_name
	]
	
	JavaScriptBridge.eval(js_payload, true)

func handle_res(result, response_code, headers, body):
	var json = JSON.new()
	api_response.emit(result, response_code, headers, json.parse(body.get_string_from_utf8()))
	
func _handle_fetch_complete(args: Array) -> void:
	print("HANDLING FETCH RESPONSE")
	var res = args[0]
	var code = args[1]
	var headers_str = args[2]
	var body_str = args[3]
	var headers = PackedStringArray()
	
	if headers_str:
		headers = PackedStringArray(
			headers_str
			.split("\n")
			.filter(
				func(h):
					return h.strip_edges() != ""
					)
				)
				
	var json = JSON.new()
	var body = json.parse(body_str)
	print("Res: " + str(res))
	print("Code: " + str(code))
	print("Headers: " + str(headers))
	print("Body: " + str(body))
	print("EMITTING API RESPONSE SIGNAL")
	api_response.emit(res, code, headers, body)

func is_data_save(_res, code, _headers, body):
	if code == 200:
		if body == OK && body.data.includes(""):
			print("VALID SAVE DATA!")
			save_loaded.emit(body.data)
		else:
			print("INVALID SAVE DATA!")
			print(str(body))
	else:
		print("RES CODE " + str(code))
