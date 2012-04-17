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
	PopulateArsenal();

	// Play the "open" animation.
	Window.GotoAndPlay("open");
	if(UpdatedEquipped == true)
	{
		(TGFxHudWrapper(GetPC().myHUD)).SetTimer(0.5, false, 'UpdateEquippedWeapon');
	}

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

/*
 * Starts inventory's the "close" animation.
 */
function StartCloseAnimation()
{
	TGFxHudWrapper(GetPC().myHUD).SetbOpen();
    Window.GotoAndPlay("close");
}

/*
 * Event handler for when the "close" animation is complete.
 * Fired from Flash.
 */
function OnCloseAnimComplete()
{
    TGFxHudWrapper(GetPC().myHUD).CompleteCloseTimer();
}

function AddEventListeners()
{
}

function MouseClick()
{
	StartCloseAnimation();
}

function CloseOpen()
{
	switch(equiped)
	{
		case 1:
			Window.GotoAndPlay("oneclose");
			break;
		case 2:
			Window.GotoAndPlay("twoclose");
			break;
		case 3:
			Window.GotoAndPlay("threeclose");
			break;
		case 4:
			Window.GotoAndPlay("fourclose");
			break;
	}
}

function Goto(String num) 
{
	local int num2;
	if(num == "one")
		num2 = 1;
	else if(num == "two")
		num2 = 2;
	else if(num == "three")
		num2 = 3;
	else if(num == "four")
		num2 = 4;
		
	Window.GotoAndPlay(num$"open");
	TPlayerController(GetPC()).SwitchWeapon(num2);
	equiped = num2;
	
	(TGFxHudWrapper(GetPC().myHUD)).SetTimer(0.3, false, 'CloseInventoryTimer');
}

function OpenOpen()
{
	switch(equiped)
	{
		case 1:
			Window.GotoAndPlay("oneopen");
			break;
		case 2:
			Window.GotoAndPlay("twoopen");
			break;
		case 3:
			Window.GotoAndPlay("threeopen");
			break;
		case 4:
			Window.GotoAndPlay("fouropen");
			break;
	}
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

function UpdateEquippedWeapon()
{
    local int CurrentWeaponGroup;
	local string str;
	str = "one";
	CurrentWeaponGroup = TWeapon(GetPC().Pawn.Weapon).GetInventorySlot();
	switch(CurrentWeaponGroup)
	{
		case 1:
			str = "one";
			break;
		case 2:
			str = "two";
			break;
		case 3:
			str = "three";
			break;
		case 4:
			str = "four";
			break;
	}
	Window.GotoAndPlay(str$"open");
	
	equiped = CurrentWeaponGroup;
}


function SwitchWeapon(byte index)
{
    TPlayerController(GetPC()).SwitchWeapon(index);
}

function int GetOpen()
{
	return equiped;
}

function SetOpen(int newEquiped)
{
	if(newEquiped == 0)
	{
		equiped = 4;
	}
	else if (newEquiped == 5)
	{
		equiped = 1;
	}
	else
	{
		equiped = newEquiped;
	}
	TPlayerController(GetPC()).SwitchWeapon(equiped);
}

defaultproperties
{
	bIgnoreMouseInput=TRUE
    bEnableGammaCorrection = FALSE
    bDisplayWithHudOff = TRUE
	bInitialized = FALSE
	MovieInfo=SwfMovie'T.Inventory'
	
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