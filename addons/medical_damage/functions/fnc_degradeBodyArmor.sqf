#include "script_component.hpp"
/*
* Author: jschildt
* Returns adjusted damage values to the body hitpoint (for now, more to come eventually),
* based on the unit's ballistic vest's reduced performance after taking hits.
*
* Arguments:
* 0: Unit <Object>
* 1: Damage done to each body part <ARRAY>
*
* Return Value:
* New damage values after taking degradation into account <ARRAY>
*
* Example:
* [_unit, _allDamages] call ace_medical_engine_fnc_getItemArmor
*
* Public: No
*/
params ["_unit", "_allDamages"];
	
	private _oldBodyArmorData = _unit getVariable QEGVAR(medical,bodyArmorDegradation);
	private _oldArmorValue = _bodyArmorData select 0;
	private _hitsAbsorbed = _bodyArmorData select 1;
	private _hitsPenetrated = _bodyArmorData select 2;
	systemChat "JOOOO";
	if (_oldArmorValue == -1) then {
		_armorValue = [_unit vest, "HitChest"] call EFUNC(medical_engine, getItemArmor);
		oldArmorValue = _armorValue;
		hint str _armorValue;
	}
	
	{
		// Current result is saved in variable _x
		if ("body" in _x || "Body" in _x) then {
			_damage = _x select 0;

			if (_damage < PENETRATION_THRESHOLD) then {
				_hitsAbsorbed = _hitsAbsorbed + 1;
			} else {
				_hitsPenetrated = _hitsPenetrated + 1;
			};
			_newArmorValue == 0 max (_oldArmorValue - _armorValue * (((0.01*_hitsAbsorbed) + (0.02*_hitsPenetrated)) max 0.01)); 
			hint str _newArmorValue;
			_newBodyArmorData = [_newArmorValue, _hitsAbsorbed, _hitsPenetrated];
			_unit setVariable [QEGVAR(medical,bodyArmorDegradation), _newBodyArmorData];
			
		};
	} forEach _allDamages;
_allDamages