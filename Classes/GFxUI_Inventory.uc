class GFxUI_Inventory extends UTGFxTweenableMoviePlayer;

var GFxObject Root, Window;
var array<GFxObject> SlotsMC;
// An array with references to all of the buttons.

var array<ItemData> Items;

var float    Scale;
var float    Width, Height;
var float    rotval;

var int equiped;

var bool     bInitialized;

var array<String> Slots;
var class<TWeapon> WeaponClasses[33];

var localized string AcceptString, CancelString;

function bool Start(optional bool UpdatedEquipped)
{	
	Super.Start();
	Advance(0);
	
	AddCaptureKeys();
	if(!bInitialized)
		ConfigureInventory();

	// Play the "open" animation.
	Window.GotoAndPlay("open");

	return true;
}

function ConfigureInventory()
{
	local float x0, y0, x1, y1;

	Root = GetVariableObject("_root");
	Window = Root.GetObject("inventory");
	SlotsMC[1] = Window.GetObject("slot1");
	SlotsMC[2] = Window.GetObject("slot2");
	SlotsMC[3] = Window.GetObject("slot3");
	SlotsMC[4] = Window.GetObject("slot4");
	
	PopulateArsenal();
	AddEventListeners();

	scale = 1;
	GetVisibleFrameRect(x0, y0, x1, y1);
	Width = (x1-x0)*20;
	Height = (y1-y0)*20;
	bInitialized = true;
}

function AddCaptureKeys()
{
	AddCaptureKey('LeftMouseButton');
	AddCaptureKey('LeftMouseClick');
	AddCaptureKey('RightMouseButton');
    AddCaptureKey('one');
    AddCaptureKey('two');
    AddCaptureKey('three');
    AddCaptureKey('four');
}

function AddEventListeners()
{
}

/*
 * Populate the Arsenal with the player's inventory of weapons.
 */
function PopulateArsenal()
{
    local byte i;
	local array<TWeapon> WeaponList;
	local TPawn TP;
	TP = TPawn(GetPC().Pawn);
	
	TP.GetWeaponList(WeaponList,true);
	
	for(i = 0; i < WeaponList.Length; i++)
	{
		if(WeaponList[i] != none)
		{
			GetPC().ClientMessage("weapon"$i$"exists"$WeaponList[i].GetWeaponSubClass());
			SlotsMC[i+1].GetObject("weapons").GotoAndStopI(i*3+WeaponList[i].GetWeaponSubClass()+1);
		}
	}
	
}

function SwitchWeapon(byte index)
{
    TPlayerController(GetPC()).SwitchWeapon(index);
}

defaultproperties
{
	bIgnoreMouseInput=TRUE
    bEnableGammaCorrection = FALSE
    bDisplayWithHudOff = TRUE
	bInitialized = FALSE
	MovieInfo=SwfMovie'T.HUD.Inventory'
	
	WeaponClasses(00)=class'TWeap_Pistol_Generic';
	WeaponClasses(01)=class'TWeap_Pistol_Burst';
	WeaponClasses(02)=class'TWeap_Pistol_Revolver';
	WeaponClasses(10)=class'TWeap_Shotgun_MidPump';
	WeaponClasses(11)=class'TWeap_Shotgun_MidAuto';
	WeaponClasses(12)=class'TWeap_Shotgun_CloseWide';
	WeaponClasses(20)=class'TWeap_Assaultrifle_AK47';
	WeaponClasses(21)=class'TWeap_Assaultrifle_M16';
	WeaponClasses(22)=class'TWeap_Assaultrifle_Famas';
	WeaponClasses(30)=class'TWeap_SpecialWeapon_Sniper';
	WeaponClasses(31)=class'TWeap_SpecialWeapon_RocketLauncher';
	WeaponClasses(32)=class'TWeap_SpecialWeapon_GernadeLauncher';
	
	Slots(1) = one;
	Slots(2) = two;
	Slots(3) = three;
	Slots(4) = four;
}