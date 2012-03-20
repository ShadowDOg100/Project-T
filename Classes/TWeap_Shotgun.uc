/**
 *	TWep_Shotgun
 *
 *	Creation date: 15/11/2011 15:51
 *	Copyright 2011, Shadow, Kibbie
 */
class TWeap_Shotgun extends TWeapon
abstract;

// AI properties (for shock combos)
var bool bRegisterTarget;
var int CurrentPath;

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(Hud, out_YL, out_YPos);
}

function SetFlashLocation( vector HitLocation )
{
	local byte NewFireMode;
	if( Instigator != None )
	{
		NewFireMode = CurrentFireMode;
		Instigator.SetFlashLocation( Self, NewFireMode , HitLocation );
	}
}


simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	Super.SetMuzzleFlashparams(PSC);
	
	PSC.SetFloatParameter('Path1',0.0);
	PSC.SetFloatParameter('Path2',0.0);
	PSC.SetFloatParameter('Path3',0.0);
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (FireModeNum>1)
	{
		Super.PlayFireEffects(0,HitLocation);
	}
	else
	{
		Super.PlayFireEffects(FireModeNum, HitLocation);
	}
}

defaultproperties
{
    FireInterval(0)=0.0
    FireInterval(1)=0.0

    Spread(0)=0.0
    Spread(1)=0.0

    ShotCost(0)=1.0
    ShotCost(1)=0.0

    InventorySlot = 2
}
