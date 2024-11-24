extends Node2D

var incidents = {
    "incident1": preload("res://incidents/incident_1/incident_1.tscn").instantiate(),
    "incident2": preload("res://incidents/incident_2/incident_2.tscn").instantiate(),
    "incident3": preload("res://incidents/incident_3/incident_3.tscn").instantiate(),
    # "incident4": preload("res://incidents/incident_4/incident_4.tscn").instantiate(),
    # "incident5": preload("res://incidents/incident_5/incident_5.tscn").instantiate(),
    # "incident6": preload("res://incidents/incident_6/incident_6.tscn").instantiate()
}

func _ready():
    for incident in incidents:
        add_child(incidents[incident])


func get_salary_paid() -> int:
    var total_salary_paid = 0
    for incident in incidents:
        if incidents[incident]["incident_resolved"]:
            total_salary_paid += incidents[incident]["salary"]
    return total_salary_paid

func get_max_bonus() -> int:
    var total_max_bonus = 0
    for incident in incidents:
        if incidents[incident]["incident_resolved"]:
            total_max_bonus += incidents[incident]["max_bonus"]
    return total_max_bonus

func get_total_resources_provided() -> int:
    var total_resources_provided = 0
    for incident in incidents:
        if incidents[incident]["incident_resolved"]:
            total_resources_provided += incidents[incident].get_resources_provided()
    return total_resources_provided

func get_resources_expended() -> int:
    var total_resources_expended = 0
    for incident in incidents:
        if incidents[incident]["incident_resolved"]:
            total_resources_expended += incidents[incident]["resources_expended"]
    return total_resources_expended

func get_performance_bonus_percentage(total_resources_provided, total_resources_expended) -> int:
    if total_resources_provided == 0:
        return 0
    return total_resources_expended / total_resources_provided

func get_total_compensation() -> int:
    return get_salary_paid() + get_max_bonus() * get_performance_bonus_percentage(get_total_resources_provided(), get_resources_expended())

func get_final_display_text() -> String:
    var compensation = get_total_compensation()
    var final_display_text = ""

    # first incident not completed
    if compensation < 2320:
        final_display_text = "
            You are dead.
            Your family cannot afford air.
            Your family cannot afford water.
            Your family cannot afford food.
            Your family cannot afford rent.
            Your family cannot afford medical care.
            Your family cannot afford an education.

            To get a good job.

            Like yours.
            "
        return final_display_text
    # second incident not completed
    elif compensation < 4640:
        final_display_text = "
            You are dead.
            Your family can afford air.
            Your family cannot afford water.
            Your family cannot afford food.
            Your family cannot afford rent.
            Your family cannot afford medical care.
            Your family cannot afford an education.

            To get a good job.

            Like yours.
            "
    elif compensation < 12000:
        final_display_text = "
            You are dead.
            Your family can afford air.
            Your family can afford water.
            Your family cannot afford food.
            Your family cannot afford rent.
            Your family cannot afford medical care.
            Your family cannot afford an education.

            To get a good job.

            Like yours.
            "
    elif compensation < 25000:
        final_display_text = "
            You are dead.
            Your family can afford air.
            Your family can afford water.
            Your family can afford food.
            Your family cannot afford rent.
            Your family cannot afford medical care.
            Your family cannot afford an education.

            To get a good job.

            Like yours.
            "
    elif compensation < 50000:
        final_display_text = "
            You are dead.
            Your family can afford air.
            Your family can afford water.
            Your family can afford food.
            Your family can afford rent.
            Your family can afford medical care.
            Your family cannot afford an education.

            To get a good job.

            Like yours.
            "
    else:
        final_display_text = "
            You are dead.
            Your family can afford air.
            Your family can afford water.
            Your family can afford food.
            Your family can afford rent.
            Your family can afford medical care.
            Your family can afford an education.

            To get a good job.

            Like yours.
            "

    return final_display_text
