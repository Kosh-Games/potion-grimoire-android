extends Node

# Assuming the plugin's singleton is named "GodotPlayGameServices"
# Adjust based on the actual plugin API
@export var api_server_url := 'https://grimoire-api-dev.kosh.games/'

var gpgs_auth_token = null # To store the server auth code

func _ready():
	print(Engine.get_singleton_list())
	if Engine.has_singleton("GodotPlayGameServices"):
		var gpgs: Object = Engine.get_singleton("GodotPlayGameServices")
		# Connect signals for sign-in results
		gpgs.connect("sign_in_success", Callable(self, "_on_gpgs_sign_in_success"))
		gpgs.connect("sign_in_failed", Callable(self, "_on_gpgs_sign_in_failed"))
		gpgs.connect("request_server_side_access_success", Callable(self, "_on_gpgs_server_auth_code_success"))
		gpgs.connect("request_server_side_access_failed", Callable(self, "_on_gpgs_server_auth_code_failed"))

		# Attempt to sign in (or show a button to trigger this)
		gpgs.sign_in()
	else:
		print("Google Play Games Services plugin not found.")

func _on_gpgs_sign_in_success():
	print("GPGP Signed in successfully!")
	# Now request the server auth code
	var gpgs: Object = Engine.get_singleton("GodotPlayGameServices")
	# IMPORTANT: Use your WEB OAuth 2.0 Client ID here (the one for your server)
	var web_client_id: String = "1066593543-8c5f1cqfvs6n4dro4kmf4fe4q3si15q2.apps.googleusercontent.com"
	gpgs.request_server_side_access(web_client_id, false) # false for not forcing refresh token, true if needed

func _on_gpgs_sign_in_failed(error_code):
	print("GPGP Sign in failed. Error: ", error_code)
	# Handle error, maybe show a button to retry

func _on_gpgs_server_auth_code_success(server_auth_code):
	print("GPGP Server Auth Code received: ", server_auth_code)
	gpgs_auth_token = server_auth_code
	# Now send this gpgs_auth_token to your FastAPI server
	send_token_to_server("google", gpgs_auth_token)

func _on_gpgs_server_auth_code_failed(error_code):
	print("GPGP Failed to get Server Auth Code. Error: ", error_code)
	# Handle error

func send_token_to_server(platform: String, token: String):
	print('ready to send the token to the server')
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_auth_request_completed"))

	var body: String            = JSON.stringify({"platform": platform, "token": token})
	var headers: Array[Variant] = ["Content-Type: application/json"]
	var error                   = http_request.request("{server_url}/auth/login".format({"server_url": api_server_url}), headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("An error occurred in the HTTP request.")

