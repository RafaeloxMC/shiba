extends Node

const API_BASE: String = "https://shibadb.xvcf.dev/api/v1"
var api_key: String = ""
var req

func _ready() -> void:
	pass
	
func init_shibadb(key: String):
	api_key = key
	req = HTTPRequest.new()
	req.request_completed.connect(self.handle_res)
	print("ShibaDB initialized!")
	
func save_progress(values: Dictionary[String, Variant]) -> void:
	if OS.get_name() != "Web":
		print("Dynamically saving progress is not supported on this platform!")
		return
	
	var payload = "{\"saveData\": " + JSON.stringify(values) + "}"
	print(payload)
	
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	
	var callback_name = "godot_shibadb_callback_" + str(Time.get_ticks_msec())
	
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
	
	print(js_payload)
	
	JavaScriptBridge.eval(js_payload, true)

func save_progress_with_cookie(values: Dictionary[String, Variant], cookie: String) -> void:
	var payload = JSON.stringify(values, "\t")
	print(payload)

	add_child(req)
	
	var err = req.request("https://shibadb.xvcf.dev/api/v1/games/" + api_key + "/data", ["Cookie: shibaCookie=" + cookie], HTTPClient.METHOD_POST, "{\"saveData\":" + payload + "}")
	if err != OK:
		print("Something went wrong while requesting ShibaDB!\n" + str(err))

func handle_res(result, response_code, headers, body):
	var json = JSON.new()
	print("Result: " + str(result))
	print("Response Code: " + str(response_code))
	print("Headers: " + str(headers))
	print("Body: " + str(json.parse(body.get_string_from_utf8())))
	
func _handle_fetch_complete(args: Array) -> void:
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
	pass
