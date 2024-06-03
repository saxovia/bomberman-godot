extends Area2D

signal coll_check(me,body)


func _on_body_entered(body):
	coll_check.emit(self,body)
