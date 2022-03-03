#include "script_component.hpp"
/*
* Author: jschildt
* Returns adjusted damage values to the body hitpoint (for now, more to come eventually),
* based on the unit's ballistic vest's reduced performance after taking hits.
*
* Arguments:
* 0: Unit <Object>
* 1: damage done to each body part <ARRAY>
*
* Return Value:
* New damage values after taking degradation into account <ARRAY>
*
* Example:
* [_unit, _alldamages] call ace_medical_engine_fnc_getItemArmor
*
* Public: No
*/
params ["_unit", "_armorData"];

//systemChat "elp";
_oldBodyArmorData = _unit getVariable QEGVAR(medical,bodyArmorDegradation);
_armor = (_oldBodyArmorData select 3); //toFixed 4;
_currentArmor = (_oldBodyArmorData select 0); //toFixed 4;
_hitsAbsorbed = (_oldBodyArmorData select 1);
_hitsPenetrated = (_oldBodyArmorData select 2);
_damage = (_armorData select 0 select 0);
_hitPoint = (_armorData select 0 select 1);
_damageBeforeArmor = (_armorData select 0 select 2);
//systemChat format["%1", _oldBodyArmorData];

if (_currentArmor isEqualTo -1) then {
        _armor = ([_unit, "HitChest"] call EFUNC(medical_engine,getHitpointArmor));
        _currentArmor = _armor;
};

if (_damage < PENETRATION_THRESHOLD) then {
    _hitsAbsorbed = _hitsAbsorbed + 1;
} else {
    _hitsPenetrated = _hitsPenetrated + 1;
    _hitsAbsorbed = _hitsAbsorbed + 1;
};

if (_hitsAbsorbed == 0 && _hitsPenetrated == 0) then {
    _currentArmor = _armor;
} else {
    _currentArmor = 2 max (_armor - _armor * (((_hitsAbsorbed)^2)/100) * (_hitsPenetrated max 1));
};

//systemChat format["(Armor) Current: %1, Original: %2", _currentArmor, _armor];
//systemChat format["1st calc done %1",_currentArmor];
// TODO: Maybe try subtracting % instead of tracking hits e.g. 5% for absorb 10% for pen

_newDamage = _damageBeforeArmor / _currentArmor;
//systemChat format["%1 / %2 = %3",_damageBeforeArmor,_currentArmor,_newDamage];
_newDamageBeforeArmor = _newDamage * _currentArmor;
//systemChat format["%1 * %2 = %3",_damageBeforeArmor,_currentArmor,_newDamageBeforeArmor];


_newBodyArmorData = [_currentArmor, _hitsAbsorbed, _hitsPenetrated, _armor];
//systemChat format["%1", _newBodyArmorData];
_unit setVariable [QEGVAR(medical,bodyArmorDegradation), _newBodyArmorData];

//systemChat format["%1, %2, %3", (_armorData select 0 select 0), (_armorData select 0 select 2), _hitPoint];
(_armorData select 0) set [0, _newDamage];
(_armorData select 0) set [2, _newDamageBeforeArmor];
_armorData