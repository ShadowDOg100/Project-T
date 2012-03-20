class TWeap_Assaultrifle extends TWeapon
	abstract;

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(Hud, out_YL, out_YPos);
}

defaultproperties
{
	InventorySlot = 3;
}