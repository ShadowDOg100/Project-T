/**
 *	TWep_Assault
 *
 *	Creation date: 15/11/2011 15:51
 *	Copyright 2011, Shadow
 */
class TWeap_Assaultrifle extends TWeapon
	abstract;

/** Animations to play before firing the beam */

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(Hud, out_YL, out_YPos);
}

defaultproperties
{
	InventorySlot = 3;
}
