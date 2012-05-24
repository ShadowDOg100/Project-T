class TWeap_Knife extends TWeapon;

simulated state Active
{
    
}

simulated state WeaponFiring
{

}

defaultproperties
{
        bInstantHit = false
	FireInterval(0) = 0.5
	InventorySlot = 3;
	WeaponSubClass = 3;
}