extends Node2D

var incidents = {
    "incident1": preload("res://incidents/incident_1/incident_1.tscn").instantiate(),
    "incident2": preload("res://incidents/incident_2/incident_2.tscn").instantiate(),
    "incident3": preload("res://incidents/incident_3/incident_3.tscn").instantiate(),
    "incident4": preload("res://incidents/incident_4/incident_4.tscn").instantiate(),
    "incident5": preload("res://incidents/incident_5/incident_5.tscn").instantiate(),
    "incident6": preload("res://incidents/incident_6/incident_6.tscn").instantiate()
}

var player_status = "Alive"
var bonus_eligibility = 66078

func _ready():
    Events.connect("player_ship_hit", _on_player_ship_hit)
    Events.connect("resources_expended", _on_resources_expended)
    for incident in incidents:
        add_child(incidents[incident])

func _on_player_ship_hit():
    player_status = "Dead"

func _on_resources_expended(amount: int):
    bonus_eligibility -= amount

func get_bonus_eligibility() -> int:
    return bonus_eligibility

func get_salary_paid() -> int:
    var total_salary_paid = 0
    for incident in incidents:
        if incidents[incident]["incident_resolved"]:
            total_salary_paid += incidents[incident]["salary"]
    return total_salary_paid

# func get_max_bonus() -> int:
#     var total_max_bonus = 0
#     for incident in incidents:
#         if incidents[incident]["incident_resolved"]:
#             total_max_bonus += incidents[incident]["max_bonus"]
#     return total_max_bonus

# func get_resources_expended() -> int:
#     var total_resources_expended = 0
#     for incident in incidents:
#         if incidents[incident]["incident_resolved"]:
#             total_resources_expended += incidents[incident]["resources_expended"]
#     return total_resources_expended

func get_total_compensation() -> int:
    return get_salary_paid() + get_bonus_eligibility()

func get_final_display_text() -> String:
    $Ambiance.stop()
    var compensation = get_total_compensation()
    var final_display_text = ""

    # first incident not completed
    if compensation < 2320:
        final_display_text = "
You are " + player_status + ".
Your family cannot afford
air.
Your family cannot afford
water.
Your family cannot afford
food.
Your family cannot afford
rent.
Your family cannot afford
medical care.
Your family cannot afford
an education.

To get a good job.

Like yours.
            "
        return final_display_text
    # second incident not completed
    elif compensation < 4640:
        final_display_text = "
You are " + player_status + ".
Your family can afford
air.
Your family cannot afford
water.
Your family cannot afford
food.
Your family cannot afford
rent.
Your family cannot afford
medical care.
Your family cannot afford
an education.

To get a good job.

Like yours.
            "
    elif compensation < 12000:
        final_display_text = "
You are " + player_status + ".
Your family can afford
air.
Your family can afford
water.
Your family cannot afford
food.
Your family cannot afford
rent.
Your family cannot afford
medical care.
Your family cannot afford
an education.

To get a good job.

Like yours.
            "
    elif compensation < 25000:
        final_display_text = "
You are " + player_status + ".
Your family can afford
air.
Your family can afford
water.
Your family can afford
food.
Your family cannot afford
rent.
Your family cannot afford
medical care.
Your family cannot afford
an education.

To get a good job.

Like yours.
            "
    elif compensation < 50000:
        final_display_text = "
You are " + player_status + ".
Your family can afford
air.
Your family can afford
water.
Your family can afford
food.
Your family can afford
rent.
Your family can afford
medical care.
Your family cannot afford
an education.

To get a good job.

Like yours.
            "
    else:
        final_display_text = "
You are " + player_status + ".
Your family can afford
air.
Your family can afford
water.
Your family can afford
food.
Your family can afford
rent.
Your family can afford
medical care.
Your family can afford
an education.

To get a good job.

Like yours.
            "

    return final_display_text
