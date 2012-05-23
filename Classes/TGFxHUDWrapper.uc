class TGFxHudWrapper extends THUDBase;

/** Main Heads Up Display Flash movie */
var GFxTHUD   HudMovie;

/** Movie for non-functional sample inventory management UI */
var GFxUI_Inventory      InventoryMovie;

/** Movie for weapon pickup */
var GFxUI_PickUp PickupMovie;

var String switchNum;
var bool bOpen;
var bool bTouch;

// Pickup
var TPickup PickupActor;

singular event Destroyed()
{
	RemoveMovies();

	Super.Destroyed();
}

/**
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if ( HUDMovie != None )
	{
		HUDMovie.Close(true);
		HUDMovie = None;
	}
	if (InventoryMovie != None)
	{
		InventoryMovie.Close(true);
		InventoryMovie = None;
	}
	Super.RemoveMovies();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CreateHUDMovie();
}

/**
  * Create and initialize the HUDMovie.
  */
function CreateHUDMovie()
{
	HudMovie = new class'GFxTHUD';
	HUDMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
	HUDMovie.SetTimingMode(TM_Real);
	HUDMovie.Start();
}

/**
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return HudMovie.LocalPlayerOwnerIndex;
}

/**
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	Super.SetVisible(bNewVisible);
}

/**
  * Called when pause menu is opened
  */
function CloseOtherMenus()
{
	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.StartCloseAnimation();
		return;
	}
}


/**
  * Recreate movies since resolution changed (also creates them initially)
  */
function ResolutionChanged()
{
	local bool bNeedInventoryMovie;

	bNeedInventoryMovie = InventoryMovie != none && InventoryMovie.bMovieIsOpen;
	super.ResolutionChanged();

	CreateHUDMovie();
	if ( bNeedInventoryMovie )
	{
		OpenWeaponSelection();
	}
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	super.PostRender();

	if (HudMovie != none)
		HudMovie.TickHud(0);
	else
		CreateHUDMovie();

	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.Tick(RenderDelta);
	}

	DrawHud();
}

/**
  * Call PostRenderFor() on actors that want it.
  */
event DrawHUD()
{
	local float XL, YL, YPos;

	bGreenCrosshair = false;

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

exec function MouseClick()
{

	if( !InventoryMovie.bMovieIsOpen )
		return;
	if(!bOpen)
		return;
	if ( PlayerOwner.Pawn != None )
	{
		if (InventoryMovie == None)
		{
			InventoryMovie = new class'GFxUI_Inventory';
		}
		ClearTimer('CloseInventory');
		InventoryMovie.MouseClick();
	}
}

/*
 * Toggle for  3D Inventory menu.
 */
exec function OpenWeaponSelection(optional string mouse)
{
	local bool start;
	local int equiped;

	if(!bOpen)
		return;

	start = true;
	if ( PlayerOwner.Pawn != None )
	{
		if (InventoryMovie == None)
		{
			InventoryMovie = new class'GFxUI_Inventory';
		}

		if( InventoryMovie.bMovieIsOpen )
		{
			equiped = InventoryMovie.GetOpen();
			InventoryMovie.CloseOpen();
			if(mouse == "up")
			{
				InventoryMovie.SetOpen(equiped-1);
			}
			else if (mouse == "down")
			{
				InventoryMovie.SetOpen(equiped+1);
			}
			SetTimer(0.3, false, 'OpenOpen');
			ClearTimer('CloseInventory');
			SetTimer(1, false, 'CloseInventory');
		}
		else
		{
			InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
			InventoryMovie.SetTimingMode(TM_Real);
			InventoryMovie.Start(start);
			SetTimer(1, false, 'CloseInventory');
		}

	}
}

exec function GotoOpenWeaponSelection(string num)
{
	local bool open;

	if(!bOpen)
		return;

	open = false;
	if ( PlayerOwner.Pawn != None )
	{
		if (InventoryMovie == None)
		{
			InventoryMovie = new class'GFxUI_Inventory';
		}

		InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
		InventoryMovie.SetTimingMode(TM_Real);
		InventoryMovie.Start(open);
		switchNum = num;
		SetTimer(0.7, false, 'GotoInventoryTimer');
	}
}

function SetbOpen()
{
	bOpen = false;
}

function OpenOpen()
{
	InventoryMovie.OpenOpen();
}

function UpdateEquippedWeapon()
{
	InventoryMovie.UpdateEquippedWeapon();
}

function CloseInventoryTimer()
{
	InventoryMovie.StartCloseAnimation();
}

function GotoInventoryTimer()
{
	InventoryMovie.Goto(switchNum);
}

function CloseInventory()
{
	SetTimer(0.1, false, 'CloseInventoryTimer');
}

function CompleteCloseTimer()
{
	if ( InventoryMovie != none )
	{
		InventoryMovie.Close(false);
		bOpen = true;
	}
}

/*
// Weapon Pickup
function ToggleWeaponPickup()
{
	local array<TWeapon> WeaponList;
	local int num1, num2;
	local TPawn TP;
	local String message;

	TP = TPawn(PlayerOwner.Pawn);
	if ( PlayerOwner.Pawn != None )
	{
		if (PickupMovie == None)
		{
			PickupMovie = new class'GFxUI_PickUp';
		}

		if(!PickupMovie.bMovieIsOpen)
		{
			num1 = PickupActor.GetWeapSlot();
			num2 = PickupActor.GetWeapSubClass();
			TP.GetWeaponList(WeaponList,true);
			message = "pickup";
			if(WeaponList[num1] != None)
			{
				if(WeaponList[num1].GetWeaponSubClass() != num2)
				{
					message = "swap";
				}
			}
			PickupMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
			PickupMovie.SetTimingMode(TM_Real);
			PickupMovie.Start();
			PickupMovie.setText(message);
		}
		else
		{
			PickupMovie.Close(false);
		}
	}
}

// Item Pickup
function ToggleItemPickup()
{
	local TPawn TP;
	local String message;

	TP = TPawn(PlayerOwner.Pawn);
	if ( PlayerOwner.Pawn != None )
	{
		if (PickupMovie == None)
		{
			PickupMovie = new class'GFxUI_PickUp';
		}

		if(!PickupMovie.bMovieIsOpen)
		{
			message = "pickup";
			PickupMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
			PickupMovie.SetTimingMode(TM_Real);
			PickupMovie.Start();
			PickupMovie.setText(message);
		}
		else
		{
			PickupMovie.Close(false);
		}
	}
}
*/
defaultproperties
{
	bOpen = true;
	bEnableActorOverlays=true
}
