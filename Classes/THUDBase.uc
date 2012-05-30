class THUDBase extends UDKHUD
	dependson(TWeapon)
	config(Game);

/** GFx movie used for displaying pause menu */
var GFxUI_PauseMenu		PauseMenuMovie;

/** class of dynamic music manager used with this hud/gametype */

/** Cached a typed Player controller.  Unlike PawnOwner we only set this once in PostBeginPlay */
var TPlayerController TPlayerOwner;

/** Whether to let actor overlays get drawn this tick */
var bool	bEnableActorOverlays;

var TextureCoordinates ToolTipSepCoords;
var float LastTimeTooltipDrawn;

var const Texture2D IconHudTexture;

/** Holds a reference to the font to use for a given console */
var config string ConsoleIconFontClassName;

/** If true, we will allow Weapons to show their crosshairs */
var bool bCrosshairShow;

/** If true, we will alter the crosshair when it's over a friendly */
var bool bCrosshairOnFriendly;

/** Make the crosshair green (found valid friendly */
var bool bGreenCrosshair;

/** Configurable crosshair scaling */
var float ConfiguredCrosshairScaling;

/** Used to pulse crosshair size */
var float LastPickupTime;

/** Various colors */
var const color BlackColor, GoldColor;

var const color LightGoldColor, LightGreenColor;

/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** Cache viewport size to determine if it has changed */
var int ViewX, ViewY;

var bool bHudMessageRendered;

simulated function PostBeginPlay()
{
	local Pawn P;

	super.PostBeginPlay();

	TPlayerOwner = TPlayerController(PlayerOwner);

	SetTimer(1.0, true);

	// add actors to the PostRenderedActors array
	ForEach DynamicActors(class'Pawn', P)
	{
		if ( (TPawn(P) != None) || (UTVehicle(P) != None) )
			AddPostRenderedActor(P);
	}

	// find the controller icons font
	ConsoleIconFont=Font(DynamicLoadObject(ConsoleIconFontClassName, class'font', true));
}

simulated event Timer()
{
	Super.Timer();
}


exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}

/** 
  * Reset movies since resolution changed
  */
function ResolutionChanged()
{
	local bool bNeedPauseMenuMovie;

	bNeedPauseMenuMovie = PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen;

	RemoveMovies();
	if ( bNeedPauseMenuMovie )
	{
		TogglePauseMenu();
	}
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	// Clear the flag
	bHudMessageRendered = false;

	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;

	if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
	{
		ResolutionChanged();
		ViewX = Canvas.ClipX;
		ViewY = Canvas.ClipY;
	}
}

/** 
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if (PauseMenuMovie != None)
	{
		PauseMenuMovie.Close(true);
		PauseMenuMovie = None;
	}
}

/** 
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	bEnableActorOverlays = bNewVisible;
	bShowHUD = bNewVisible;
}

/** 
  * Called when pause menu is opened
  */
function CloseOtherMenus();

/*
 * Toggle the Pause Menu on or off.
 * 
 */
function TogglePauseMenu()
{
    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
	{
		
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.PlayCloseAnimation();
		}
		else
		{
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	}
	else
    {
		CloseOtherMenus();

        PlayerOwner.SetPause(True);

        if (PauseMenuMovie == None)
        {
	        PauseMenuMovie = new class'GFxUI_PauseMenu';
            PauseMenuMovie.MovieInfo = SwfMovie'UDKHud.udk_pausemenu'; //movie for pause menu
            PauseMenuMovie.bEnableGammaCorrection = FALSE;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenuMovie.SetTimingMode(TM_Real);
        }

		SetVisible(false);
        PauseMenuMovie.Start();
        PauseMenuMovie.PlayOpenAnimation();

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
		}
    }
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    PauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
    SetVisible(true);
}

/** 
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
}

defaultproperties
{
	ToolTipSepCoords=(U=260,V=379,UL=29,VL=27)
	IconHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseB'
	BindTextFont=MultiFont'UI_Fonts_Final.HUD.MF_Large'
	ConfiguredCrosshairScaling=1.0

	BlackColor=(R=0,G=0,B=0,A=255)
	GoldColor=(R=255,G=183,B=11,A=255)
	LightGoldColor=(R=255,G=255,B=128,A=255)
	LightGreenColor=(R=128,G=255,B=128,A=255)
}


