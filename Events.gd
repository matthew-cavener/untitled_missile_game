extends Node


signal button_1_pressed
signal button_2_pressed
signal button_3_pressed
signal button_4_pressed
signal button_5_pressed
signal button_6_pressed
signal button_7_pressed
signal button_8_pressed


signal launch_tube_1
signal launch_tube_2
signal launch_tube_3
signal launch_tube_4
signal launch_tube_5
signal launch_tube_6

signal incident_1_begin
signal incident_2_begin
signal incident_3_begin
signal incident_4_begin
signal incident_5_begin
signal incident_6_begin

signal incident_1_resolved
signal incident_2_resolved
signal incident_3_resolved
signal incident_4_resolved
signal incident_5_resolved
signal incident_6_resolved

signal all_clear(all_clear: bool)
signal caution
signal warning

signal ciws_available(ciws_available: bool)
signal ciws_started_firing
signal ciws_stopped_firing
signal player_ship_hit

signal ping(ping_source: Node)

signal resources_expended(amount: int)

signal missile_launch(launch_source: Node, boost_time: float)
signal missile_hit

signal incident_resolved
