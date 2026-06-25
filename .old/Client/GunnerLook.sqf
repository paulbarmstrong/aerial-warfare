disableSerialization;

_man = _this;

while {alive _man} do {
	group _man setBehaviour "CARELESS";
	_man doWatch screenToWorld[0.5,0.5];
	
	hint format["do %1",screenToWorld[0.5,0.5]];
	sleep 1;
};


