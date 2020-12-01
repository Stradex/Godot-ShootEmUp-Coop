extends Node
const SNAPSHOT_DELAY = 1.0/30.0; #Msec to Sec
const MAX_PLAYERS:int = 4;
const SERVER_PORT:int = 27666;
const SERVER_NETID: int = 1;
var clients_connected: Array;
var player_count: int = 1;
var game_score: int = 0;

const MAX_CLIENT_LATENCY: float = 0.4; #350ms
const MAX_MESSAGE_PING_BUFFER: int = 8; #Average from ammount
var pings: Array; 
var client_latency: float = 0.0;
var ping_counter = 0.0;
var LevelScene: Node = null;

func _ready():
	clients_connected.clear();
	get_tree().connect("network_peer_connected", self, "_on_player_connected");
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnect");

func _process(delta):
	if get_tree().has_network_peer() && !is_network_master():
		if ping_counter <=  0.0 || ping_counter > 2.0:
			client_send_ping(); #resend, just in case.
		ping_counter+=delta;

func _on_player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	clients_connected.append({netId = id, ingame = false})
	player_count+=1;

func _on_player_disconnect(id):
	clients_connected.remove(id);

func clear_players():
	var is_server: bool = false;
	for info in clients_connected:
		info.ingame = false;
		if info.netId == 1:
			is_server = true;
	if !is_server:
		clients_connected.append({netId = 1, ingame = false})

func client_send_ping():
	ping_counter = 0.0;
	rpc_unreliable_id(Game.SERVER_NETID, "server_receive_ping", get_tree().get_network_unique_id());

remote func server_receive_ping(id_client):
	self.rpc_unreliable_id(id_client, "client_receive_ping");

remote func client_receive_ping():
	pings.append(ping_counter);
	if pings.size() >= MAX_MESSAGE_PING_BUFFER:
		pings.pop_front();
	ping_counter = 0.0;
	var sum_pings: float = 0.0;
	for ping in pings:
		sum_pings+=ping;
	client_latency = sum_pings / float(pings.size());
	if typeof(LevelScene) != TYPE_NIL:
		LevelScene.update_latency();
