extends Control

var clients_joined: int = 1;

func _ready():
	Game.clients_connected.clear();
	Game.player_count = 1;
	$HostServer.connect("pressed", self, "host_server");
	$Connect.connect("pressed", self, "join_server");
	get_tree().connect("connected_to_server", self, "_on_connected_to_server");
	get_tree().connect("network_peer_connected", self, "_on_player_connected");

func host_server():
	var host = NetworkedMultiplayerENet.new();
	host.create_server(Game.SERVER_PORT, Game.MAX_PLAYERS);
	get_tree().set_network_peer(host);
	$HostServer.text = "Waiting for player....";
	$HostServer.disabled = true;
	$Connect.disabled = true;
	#get_tree().change_scene("res://stage.tscn");

func join_server():
	var IPAddress: String = $IP.text;
	IPAddress = IPAddress.replace(" ", "");
	var host = NetworkedMultiplayerENet.new();
	host.create_client(IPAddress, Game.SERVER_PORT);
	get_tree().set_network_peer(host);

func _on_player_connected(id):
	var max_players: int = int($MaxClients.text);
	if !get_tree().is_network_server():
		return;
	clients_joined+=1;
	if clients_joined >= max_players:
		get_tree().change_scene("res://stage.tscn");

func _on_connected_to_server():
	if get_tree().is_network_server():
		return;
	get_tree().change_scene("res://stage.tscn");
