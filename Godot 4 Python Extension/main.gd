extends Node

const MY_IP = "127.0.0.1"

const PORT = 42799



var peers = []
var process_pids := []

# Directory for exported version
var DIR = OS.get_executable_path().get_base_dir()
var interpreter_path = DIR+"PythonFiles/venv/Scripts/python.exe"
var script_path = DIR+"PythonFiles/main.py"

var server := UDPServer.new()

var json = JSON.new()

var thread: Thread

func _ready():
	
	server.listen(PORT)

	
	if !OS.has_feature("standalone"): # if NOT exported version
		interpreter_path = ProjectSettings.globalize_path("res://PythonFiles/venv/Scripts/python.exe")
		script_path = ProjectSettings.globalize_path("res://PythonFiles/main.py")
	
	#The os.execute have to be ran on a thread because if not it will block other things from running.
	thread = Thread.new()
	thread.start(runPython.bind())



func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		kill_processes()
		get_tree().quit() # default behavior



func _process(_delta):
	#Receive first value
	server.poll()
	if server.is_connection_available():
		print("CONNECTION AVAILABLE")
		
		var peer : PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet().get_string_from_utf8()
		
		
		process_pids.append(packet)
		peers.append(peer)

	#Receive data from python
	for i in peers:
		if i.get_available_packet_count() > 0:
			var bytes:PackedByteArray = i.get_packet()
			var data = bytes.get_string_from_utf8()
			print("RECEIVE DATA: "+data)
	
	#Press space to send data to python
	if Input.is_action_pressed("ui_accept"):
		var send_data = "Hello"
		var bytes = send_data.to_utf8_buffer()
		
		for i:PacketPeerUDP in peers:
			i.put_packet(bytes) 

func runPython():
	var output = []
	OS.execute(interpreter_path, PackedStringArray([script_path,PORT]),output,true,true)
	print("PYTHON OUTPUT: ",output)


func kill_processes():
	#Close the python programs when godot runtime is closed.
	for pid in process_pids:
		OS.kill(float(pid))
		

func _exit_tree():
	thread.wait_to_finish()
	server.stop()
