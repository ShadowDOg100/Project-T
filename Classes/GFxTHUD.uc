class GFxTHUD extends GFxMoviePlayer;

var WorldInfo    ThisWorld;

var GFxObject    RootMC, MiniMapMC, HealthMC, HealthTF, ArmorMC, ArmorTF;

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
	MiniMapMC = RootMC.GetObject("MiniMap");
	HealthMC = MiniMapMC.GetObject("HealthBar");
	HealthTF = MiniMapMC.GetObject("HealthTF");
	ArmorMC = MiniMapMC.GetObject("ArmorBar");
	ArmorTF = MiniMapMC.GetObject("ArmorTF");
	
    MiniMapMC.SetFloat("_yrotation", 15);
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
		LastHealth = -10;
	}
	if (LastArmor != -10)
	{
		ArmorTF.SetString("text", "");
		LastArmor = -10;
	}
	if (LastAmmoCount != -10)
	{
		LastAmmoCount = -10;
	}
	if (LastClipCount != -10)
	{
		LastAmmoCount = -10;
	}
	if (LastWeapon != none)
	{
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
	local ASValue armor;
	local bool update;

	update = false;

	PC = GetPC();

	TP = TPawn(PC.Pawn);
	
	if (LastHealth != TP.Health)
	{
		LastHealth = TP.Health;
		health.Type = ASType.AS_Number;
		health.n = TP.Health;
		args[0] = health;
		HealthTF.SetText(""$(int(LastHealth)));
		PC.ClientMessage(TP.Health);
		update = true;
	}
	else
	{
		health.Type = ASType.AS_Number;
		health.n = LastHealth;
		args[0] = health;
	}
	if (LastArmor != TP.armor)
	{
		LastArmor = TP.armor;
		armor.Type = ASType.AS_Number;
		armor.n = TP.armor;
		args[1] = armor;
		ArmorTF.SetText(""$LastArmor);
		PC.ClientMessage(TP.armor);
		update = true;
	}
	else
	{
		armor.Type = ASType.AS_Number;
		armor.n = LastArmor;
		args[1] = armor;
	}

	if(update)
	{
		Invoke("damage", args);
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
			//AmmoTF.SetText(i);
			//ClipTF.SetText(j);
		}
	}
}

defaultproperties
{
	bDisplayWithHudOff=FALSE
	MovieInfo=SwfMovie'T.UI.THUD'
	bEnableGammaCorrection=false

	bAllowInput=FALSE;
	bAllowFocus=FALSE;
}
