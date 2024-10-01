@tool
extends MeshInstance3D

@export
var vertices = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	#mesh_data(ArrayMesh.ARRAY_VERTEX) = PoolVector3Array()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
