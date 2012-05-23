class GFxTHUD extends GFxMoviePlayer;

var WorldInfo    ThisWorld;

var GFxObject    RootMC, PlayerStatsMC, HealthMC, HealthTF, AmmoMC, ClipTF, AmmoTF;

var TWeapon      LastWeapon;
var float        LastHealth, LastArmor;
var int          LastAmmoCount, LastClipCount;

/*
 * Initialization method for HUD.
 * 
 * Caches all the references to MovieClips that will be updated throughout
 * the HUD's lifespan.
 * 
 * For the record, GetVariableObject is not as fast as GFxObject::GetObject() but
 * nevertheless is used here for convenience.
 * 
 */
 
function bool Start(optional bool StartPaused)
{
	super.Start(StartPaused);
    Advance(0);
	Init();
	//PlayerStatsMC.GotoAndStopI(0);
	
	return true;
}
 
function Init(optional LocalPlayer player)
{	
	super.Init(player);
	
	ThisWorld = GetPC().WorldInfo;
	
	LastHealth = -110;
	LastArmor = -110;
	LastAmmoCount = -110;
	LastClipCount = -110;

	RootMC = GetVariableObject("_root");
	PlayerStatsMC = RootMC.GetObject("PlayerStats");
	HealthMC = PlayerStatsMC.GetObject("Health");
	HealthTF = PlayerStatsMC.GetObject("HealthP");
	AmmoTF = PlayerStatsMC.GetObject("Ammo");
	ClipTF = PlayerStatsMC.GetObject("Clip");
	AmmoMC = PlayerStatsMC.GetObject("Graphics");
	
    PlayerStatsMC.SetFloat("_yrotation", 15);
}

static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;
	Seconds -= Mins * 60;
	if (Hours > 0)
		NewTimeString = ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins)) $ ":";
	NewTimeString = NewTimeString $ ( Seconds > 9 ? String(Seconds) : "0"$String(Seconds));

	return NewTimeString;
}

function ClearStats()
{	
	if (LastHealth != -10)
	{
		HealthTF.SetString("text", "");
		//HealthBarMC.SetDisplayInfo(DI);
		LastHealth = -10;
	}
	if (LastAmmoCount != -10)
	{
		AmmoTF.SetString("text", "");
		AmmoMC.GotoAndStopI(0);
		LastAmmoCount = -10;
	}
	if (LastClipCount != -10)
	{
		ClipTF.SetString("text", "");
		AmmoMC.GotoAndStopI(0);
		LastAmmoCount = -10;
	}
	if (LastWeapon != none)
	{
		AmmoMC.GotoAndStopI(0);
		LastWeapon = none;
	}
}

function TickHud(float DeltaTime)
{
	local TPawn TP;
	local TWeapon Weapon;
	local int i, j;
	local PlayerController PC;
	local array<ASValue> args;
	local ASValue health;
	PC = GetPC();

	TP = TPawn(PC.Pawn);
	
	if (LastHealth != TP.Health)
	{
		HealthTF.SetText(TP.Health);
		LastHealth = TP.Health;
		health.Type = ASType.AS_Number;
		health.n = TP.Health;
		args[0] = health;
		Invoke("damage", args);
		PC.ClientMessage(TP.Health);
	}

	Weapon = TWeapon(TP.Weapon);
	if (Weapon != none)
	{
		if (Weapon != LastWeapon)
		{
			LastWeapon = Weapon;
		}
		i = Weapon.GetAmmoCount();
		j = Weapon.GetClipCount();
		if (i != LastAmmoCount || j != LastClipCount)
		{
			LastAmmoCount = i;
			LastClipCount = j;
			AmmoTF.SetText(i);
			ClipTF.SetText(j);
		}
		
		AmmoMC.GotoAndStopI(Weapon.GetInventorySlot() + 1);
	}
	else
	{
		AmmoMC.GotoAndStopI(0);
		ClipTF.SetText("");
		AmmoTF.SetText("");
	}
}

defaultproperties
{
	bDisplayWithHudOff=FALSE
	MovieInfo=SwfMovie'T.UI.HUD'
	bEnableGammaCorrection=false

	bAllowInput=FALSE;
	bAllowFocus=FALSE;
}
