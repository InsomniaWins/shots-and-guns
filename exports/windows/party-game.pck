GDPC                �	                                                                         X   res://.godot/exported/133200997/export-0eb146303a21b2d6053eeefd0d3da43a-titlescreen.scn �J      �      ���\��?�+�Z    X   res://.godot/exported/133200997/export-38f69c06886a7fe16b5961b0fe875aa6-join_screen.scn �&      	      �X�S�&J� �]J�.q    T   res://.godot/exported/133200997/export-93cc9a5d6803c236fbacaa3f298908de-lobby.scn   �9      �      o�S���s`Ċj6&�ޚ    X   res://.godot/exported/133200997/export-b0d538ad7b5351475868d4c8e2425960-host_screen.scn 0      �      ����)���~E��s�m    X   res://.godot/exported/133200997/export-f2dedc012c6ef79bd9852c41024305ba-test_scene.scn  �F      A      ��E=ǫ<��:�CY�    P   res://.godot/exported/133200997/export-f39996a6d27a38698d16421ab974097b-main.scn�A      �      �E�jCA�����U�    ,   res://.godot/global_script_class_cache.cfg   b             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�Q            ：Qt�E�cO���       res://.godot/uid_cache.bin   f      @      |�BQ��{Zܛ��j�]�    $   res://addons/multirun/Multirun.gd           j      acBA�ƞ+͚P���I�       res://autoload/network.gd   p      +      ��a�@p.i��d�r+        res://autoload/scene_manager.gd �      �      l�Y��G������}�       res://icon.svg  @b      �      k����X3Y���f       res://icon.svg.import   �^      �       [O����C��
��y��       res://project.binary@g      �       �jӨY���մ�
�    (   res://scenes/host_screen/host_screen.gd �      �      �Q
����������    0   res://scenes/host_screen/host_screen.tscn.remap �_      h       �	'U�{,��9]ql    (   res://scenes/join_screen/join_screen.gd  0      �	      [����Dg���+�$�    0   res://scenes/join_screen/join_screen.tscn.remap �_      h       ��mɽf�n��C       res://scenes/lobby/lobby.gd `?      �      �>����+[}�o*    $   res://scenes/lobby/lobby.tscn.remap ``      b       )B�:�>Yu�jW/       res://scenes/main/main.gd   `A      g       aq�O�,��$E�4vQ#g    $   res://scenes/main/main.tscn.remap   �`      a       >�/�e�ps�{�ܮ�0�    (   res://scenes/test_scene/test_scene.gd   `F      5       ���:�~`�Y���    0   res://scenes/test_scene/test_scene.tscn.remap   @a      g       )����ܶ���&��]�    (   res://scenes/titlescreen/titlescreen.gd �I      �       +�H�YcwK�8�<    0   res://scenes/titlescreen/titlescreen.tscn.remap �a      h       h߉�' �[xA�,T            @tool
extends EditorPlugin

var panel1
var panel2
var pids = []

func _str_args_to_commands(args:String):
	var commands : PackedStringArray = []
	for arg in args.split(" "):
		commands.append(arg)
	return commands

func _enter_tree():
	var editor_node = get_editor_interface()
	var gui_base = editor_node.get_base_control()
	var icon_transition = gui_base.get_theme_icon("TransitionSync", "EditorIcons") #ToolConnect
	var icon_transition_auto = gui_base.get_theme_icon("TransitionSyncAuto", "EditorIcons")
	var icon_load = gui_base.get_theme_icon("Load", "EditorIcons")

	panel2 = _add_tooblar_button(_loaddir_pressed.bind(), icon_load, icon_load)
	panel1 = _add_tooblar_button(_multirun_pressed.bind(), icon_transition, icon_transition_auto)

	if ProjectSettings.has_setting("debug/multirun/other_window_args"):
		ProjectSettings.set("debug/multirun/other_window_args", null)
	if ProjectSettings.has_setting("debug/multirun/window_distance"):
		ProjectSettings.set("debug/multirun/window_distance", null)
	if ProjectSettings.has_setting("debug/multirun/first_window_args"):
		ProjectSettings.set("debug/multirun/first_window_args", null)

	_add_setting("debug/multirun/number_of_windows", TYPE_INT, 2)
	_add_setting("debug/multirun/add_custom_args", TYPE_BOOL, true)
	_add_setting("debug/multirun/window_args", TYPE_ARRAY, ["listen", "join"], "%d:" % [TYPE_STRING])

func _multirun_pressed():
	var window_count : int = ProjectSettings.get_setting("debug/multirun/number_of_windows")
	var add_custom_args : bool = ProjectSettings.get_setting("debug/multirun/add_custom_args")
	var args : PackedStringArray = ProjectSettings.get_setting("debug/multirun/window_args")
	var first_args : String = ""
	var commands = _str_args_to_commands(args[0]) if add_custom_args && args else []

	first_args = " ".join(commands)

	var main_run_args = ProjectSettings.get_setting("editor/run/main_run_args")
	if main_run_args != first_args:
		ProjectSettings.set_setting("editor/run/main_run_args", first_args)
	var interface = get_editor_interface()
	interface.play_main_scene()
	if main_run_args != first_args:
		ProjectSettings.set_setting("editor/run/main_run_args", main_run_args)

	kill_pids()
	for i in range(1, window_count):
		commands = _str_args_to_commands(args[i]) if add_custom_args && args && i < args.size() else []
		pids.append(OS.create_process(OS.get_executable_path(), commands))

func _start_new_view(commands: PackedStringArray):
	pids.append(OS.create_process(OS.get_executable_path(), commands))

func _loaddir_pressed():
	OS.shell_open(OS.get_user_data_dir())

func _exit_tree():
	_remove_panels()
	kill_pids()

func kill_pids():
	for pid in pids:
		OS.kill(pid)
	pids = []

func _remove_panels():
	if panel1:
		remove_control_from_container(CONTAINER_TOOLBAR, panel1)
		panel1.free()
	if panel2:
		remove_control_from_container(CONTAINER_TOOLBAR, panel2)
		panel2.free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F4:
			_multirun_pressed()

func _add_tooblar_button(action:Callable, icon_normal, icon_pressed):
	var panel = PanelContainer.new()
	var b = TextureButton.new();
	b.texture_normal = icon_normal
	b.texture_pressed = icon_pressed
	b.connect("pressed", action.bind())
	panel.add_child(b)
	add_control_to_container(CONTAINER_TOOLBAR, panel)
	return panel

func _add_setting(thename:String, type, value, hint_str=null):
	if ProjectSettings.has_setting(thename):
		return
	ProjectSettings.set(thename, value)
	var property_info = {
		"name": thename,
		"type": type,
		"hint": PROPERTY_HINT_TYPE_STRING if hint_str != null else null,
		"hint_string": hint_str
	}
	ProjectSettings.add_property_info(property_info)
      extends Node

var players:Dictionary = {}


func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)


func peer_connected(peer_id:int) -> void:
	pass


func peer_disconnected(peer_id:int) -> void:
	players.erase(peer_id)


func create_new_player_info() -> Dictionary:
	return {
		"username": "?"
	}


func send_player_info_to_server(player_info:Dictionary) -> void:
	print(multiplayer.get_unique_id())
	got_player_info_from_peer.rpc_id(1, player_info)


@rpc("any_peer")
func got_player_info_from_peer(player_info:Dictionary) -> void:
	if !player_info.has("username"):
		return
	
	var sender:int = multiplayer.get_remote_sender_id()
	
	if !players.has(sender):
		players[sender] = create_new_player_info()
	
	players[sender]["username"] = player_info["username"]
	
	print(players)
	
	send_player_list_to_clients()


func send_player_list_to_clients() -> void:
	got_player_list_from_server.rpc()


@rpc("authority")
func got_player_list_from_server(_players:Dictionary) -> void:
	players = _players
     extends Node

signal changed_scene(current_scene)


# private func of change_scene used to defer func call
func _change_scene(next_scene_path:String, post_function:Callable) -> void:
	var next_scene:Node = load(next_scene_path).instantiate()
	var current_scene = get_current_scene()
	var current_scene_parent = get_current_scene_parent()
	var freed_scenes_parent = get_freed_scenes_parent()
	
	
	current_scene_parent.remove_child(current_scene)
	freed_scenes_parent.add_child(current_scene)
	current_scene.queue_free()
	
	current_scene_parent.add_child(next_scene)
	
	if !next_scene.is_node_ready():
		await next_scene.ready
	
	if !post_function.is_null():
		post_function.call()
	
	changed_scene.emit(next_scene)


func change_scene(next_scene_path:String, post_function:Callable = Callable()) -> void:
	_change_scene.call_deferred(next_scene_path, post_function)


func get_freed_scenes_parent() -> Node:
	return get_tree().current_scene.get_node("%FreedScenesParent")


func get_freed_scenes() -> Array[Node]:
	return get_freed_scenes_parent().get_children()


func get_current_scene_parent() -> Control:
	return get_tree().current_scene.get_node("%CurrentSceneParent")


func get_current_scene() -> Node:
	return get_current_scene_parent().get_child(0)
	


   extends Control


@onready var port_line_edit_node:LineEdit = $VBoxContainer/PortLineEdit
@onready var username_line_edit_node:LineEdit = $VBoxContainer/UsernameEdit
@onready var status_label_node:Label = $StatusLabel


func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)


func _on_host_button_pressed():
	var port:int = port_line_edit_node.text.to_int()
	var username:String = username_line_edit_node.text
	
	if username.is_empty():
		status_label_node.text = "Username cannot be left blank!"
		status_label_node.modulate = Color.RED
		return
	
	_host_server(port, username)


func _host_server(port:int, username:String):
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	
	var server_creation_result = peer.create_server(port)
	if server_creation_result != OK:
		status_label_node.text = str("Failed to make server peer: ", server_creation_result)
		status_label_node.modulate = Color.RED
		return
	
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to start server!"
		status_label_node.modulate = Color.RED
		return
	
	
	multiplayer.multiplayer_peer = peer
	
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info()
	Network.players[peer.get_unique_id()]["username"] = username
	
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	
	await SceneManager.changed_scene
	
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()
RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script (   res://scenes/host_screen/host_screen.gd ��������      local://PackedScene_aqhd3          PackedScene          	         names "   #      HostScreen    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    BackButton    offset_left    offset_top    offset_right    offset_bottom    text    Button    Label    anchor_left    horizontal_alignment    VBoxContainer    custom_minimum_size    anchor_top $   theme_override_constants/separation 
   alignment    PortLineEdit    placeholder_text 	   LineEdit    UsernameEdit    max_length    HostButton    StatusLabel    vertical_alignment    _on_back_button_pressed    pressed    _on_host_button_pressed    	   variants                        �?                             A     hB     B      BACK                   ?     :�     �A     :B   
   HOST GAME 
     HC               ��     �A   
   
          B      35516       PORT    	   USERNAME             HOST            ��      node_count             nodes     �   ��������       ����                                                             	   ����         
                           	                     ����      
                     
                                       
                     ����            
                                 
                                             
                    ����                                            ����                                            ����                                 ����
      
                                                
      
             conn_count             conns               !                         !   "                    node_paths              editable_instances              version             RSRC    RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script (   res://scenes/join_screen/join_screen.gd ��������      local://PackedScene_ba8jw          PackedScene          	         names "   $      JoinScreen    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    BackButton    offset_left    offset_top    offset_right    offset_bottom    text    Button    Label    anchor_left    horizontal_alignment    VBoxContainer    custom_minimum_size    anchor_top $   theme_override_constants/separation 
   alignment    IpLineEdit    placeholder_text 	   LineEdit    PortLineEdit    UsernameEdit    max_length    JoinButton    StatusLabel    vertical_alignment    _on_back_button_pressed    pressed    _on_join_button_pressed    	   variants                         �?                             A     hB     B      BACK                   ?     :�     �A     :B   
   JOIN GAME 
     HC               ��     �A   
   
          B      192.168.56.1       IP ADDRESS       35516       PORT    	   USERNAME             JOIN            ��      node_count    	         nodes     �   ��������       ����                                                             	   ����         
                           	                     ����      
                     
                                       
                     ����            
                                 
                                             
                    ����                                            ����                                            ����                                            ����                                 ����
      
                                                
       
             conn_count             conns               "   !                     "   #                    node_paths              editable_instances              version             RSRC extends Control

@onready var ip_line_edit_node:LineEdit = $VBoxContainer/IpLineEdit
@onready var port_line_edit_node:LineEdit = $VBoxContainer/PortLineEdit
@onready var username_line_edit_node:LineEdit = $VBoxContainer/UsernameEdit
@onready var status_label_node:Label = $StatusLabel


func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)



func _on_join_button_pressed():
	var ip:String = ip_line_edit_node.text
	var port:int = port_line_edit_node.text.to_int()
	var username:String = username_line_edit_node.text
	
	if username.is_empty():
		status_label_node.text = "Username cannot be left blank!"
		status_label_node.modulate = Color.RED
		return
	
	_join_server("127.0.0.1", port, username)


func _join_server(ip:String, port:int, username:String) -> void:
	
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var client_creation_result:int = peer.create_client(ip, port)
	
	if client_creation_result != OK:
		status_label_node.text = str("Failed to make client peer: ", client_creation_result)
		status_label_node.modulate = Color.RED
		return
	
	
	
	$BackButton.disabled = true
	$VBoxContainer/JoinButton.disabled = true
	
	const TIMEOUT:float = 4.0
	var timeout:float = TIMEOUT
	while peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		
		timeout -= get_process_delta_time()
		
		if timeout <= 0.0:
			
			status_label_node.text = str("Connection took longer than ", TIMEOUT, " seconds, timed-out!")
			status_label_node.modulate = Color.RED
			
			$BackButton.disabled = false
			$VBoxContainer/JoinButton.disabled = false
			
			peer.close()
			
			return
		
		await get_tree().process_frame
	
	
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		return
	
	
	multiplayer.multiplayer_peer = peer
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info()
	Network.players[peer.get_unique_id()]["username"] = username
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	await SceneManager.changed_scene
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	Network.send_player_info_to_server({
		"username": username
	})
RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/lobby/lobby.gd ��������      local://PackedScene_nwj44          PackedScene          	         names "         Lobby    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    Label    offset_bottom    text    horizontal_alignment    VBoxContainer    anchor_left    anchor_top    offset_left    offset_top    offset_right 
   alignment    vertical_alignment    PlayerList    	   variants                        �?                         
        �A      LOBBY             ?     �     ��     B     �A      PLAYERS       node_count             nodes     e   ��������       ����                                                          	   	   ����                     
                                          ����            	      
      
      
      
                     
                                   	   	   ����                                            ����                         conn_count              conns               node_paths              editable_instances              version             RSRC    extends Control

@onready var player_list_node:VBoxContainer = $VBoxContainer/PlayerList


func update_player_list() -> void:
	
	for child in player_list_node.get_children():
		child.queue_free()
	
	for peer_id in Network.players:
		var player_info = Network.players[peer_id]
		
		var label:Label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		if peer_id == 1:
			label.text = "* "
		
		label.text = label.text + player_info["username"]
		
		player_list_node.add_child(label)


   extends Control

#func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/main/main.gd ��������   PackedScene *   res://scenes/titlescreen/titlescreen.tscn f�f�\      local://PackedScene_inhux W         PackedScene          	         names "         Main    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    CurrentSceneParent    unique_name_in_owner    Titlescreen    FreedScenesParent    Node    	   variants                        �?                                           node_count             nodes     <   ��������       ����                                                             	   ����   
                                                     ���                                 ����   
                conn_count              conns               node_paths              editable_instances              version             RSRC   extends Control

func _ready():
	print("test scene")
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script &   res://scenes/test_scene/test_scene.gd ��������      local://PackedScene_mcde5          PackedScene          	         names "   	   
   TestScene    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    	   variants                        �?                      node_count             nodes        ��������       ����                                                        conn_count              conns               node_paths              editable_instances              version             RSRC               extends Control


func _on_host_button_pressed():
	SceneManager.change_scene("res://scenes/host_screen/host_screen.tscn")


func _on_join_button_pressed():
	SceneManager.change_scene("res://scenes/join_screen/join_screen.tscn")
            RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script (   res://scenes/titlescreen/titlescreen.gd ��������      local://PackedScene_gxhih          PackedScene          	         names "         Titlescreen    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    VBoxContainer    anchor_left    anchor_top    offset_left    offset_top    offset_right    offset_bottom $   theme_override_constants/separation 
   alignment    HostButton    text    Button    JoinButton    Label    horizontal_alignment    _on_host_button_pressed    pressed    _on_join_button_pressed    	   variants                        �?                                  ?     ��     �A   
      
   HOST GAME    
   JOIN GAME            H�     `B     HB     �B      PARTY GAME       node_count             nodes     k   ��������       ����                                                          	   	   ����               
                                       	      	                  
                          ����                                ����                                 ����               
                                                                conn_count             conns                                                              node_paths              editable_instances              version             RSRC          GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bv3p685yxo3eq"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-b0d538ad7b5351475868d4c8e2425960-host_screen.scn"
        [remap]

path="res://.godot/exported/133200997/export-38f69c06886a7fe16b5961b0fe875aa6-join_screen.scn"
        [remap]

path="res://.godot/exported/133200997/export-93cc9a5d6803c236fbacaa3f298908de-lobby.scn"
              [remap]

path="res://.godot/exported/133200997/export-f39996a6d27a38698d16421ab974097b-main.scn"
               [remap]

path="res://.godot/exported/133200997/export-f2dedc012c6ef79bd9852c41024305ba-test_scene.scn"
         [remap]

path="res://.godot/exported/133200997/export-0eb146303a21b2d6053eeefd0d3da43a-titlescreen.scn"
        list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              ��}�bn�b)   res://scenes/host_screen/host_screen.tscn�ԟ9���    res://scenes/main/main.tscn��^=�o'   res://scenes/test_scene/test_scene.tscnf�f�\)   res://scenes/titlescreen/titlescreen.tscn�91i�c6   res://icon.svg}=�&P��)   res://scenes/join_screen/join_screen.tscn$�ˆd��   res://scenes/lobby/lobby.tscnECFG      application/config/name      
   party-game     application/run/main_scene$         res://scenes/main/main.tscn    application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg     autoload/SceneManager(          *res://autoload/scene_manager.gd   autoload/Network$         *res://autoload/network.gd      debug/multirun/number_of_windows            debug/multirun/add_custom_args            debug/multirun/window_args$               listen        join"   display/window/size/viewport_width        #   display/window/size/viewport_height      F     display/window/stretch/mode         canvas_items!   display/window/stretch/scale_mode         integer #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility          