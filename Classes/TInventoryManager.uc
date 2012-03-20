class TInventoryManager extends InventoryManager
 config(Game);

var Weapon PreviousWeapon;

simulated function GetWeaponList(out array<TWeapon> WeaponList, optional bool bNoEmpty)
{
	local TWeapon Weap;
	local int i;

	ForEach InventoryActors( class'TWeapon', Weap )
	{
		i = Weap.GetInventorySlot()-1;
		if ( !bNoEmpty || Weap.HasAnyAmmo())
		{
			WeaponList[i] = Weap;
		}
		else
		{
			WeaponList[i] = none;
		}
	}
}

simulated function SwitchWeapon(byte NewGroup)
{
	local array<TWeapon> WeaponList;
	local int i;
	local bool good;
	local int k;
	local PlayerController PC;
	good = false;
	
	// Get the list of weapons

   	GetWeaponList(WeaponList,true);

	// Exit out if no weapons are in this list.

	if (WeaponList.Length<=0)
		return;

	for(i = 1; i < WeaponList.Length; i++)
	{
		if(WeaponList[i].GetInventorySlot() == NewGroup)
		{
			good = true;
			k = i;
		}
	}
	
	PC = PlayerController(Instigator.Controller);
	PC.ClientMessage("Inventory Switch");
	// Begin the switch process...
	if(good)
	{
		PC.ClientMessage("Inventory Switch");
		if ( WeaponList[k].HasAnyAmmo() )
		{
			PC.ClientMessage("Inventory Switch");
			SetCurrentWeapon(WeaponList[k]);
		}
	}
}

reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	local Weapon PrevWeapon;
	local PlayerController PC;
	PrevWeapon = Instigator.Weapon;
	PC = PlayerController(Instigator.Controller);
	
	SetPendingWeapon(DesiredWeapon);
	
	if( PrevWeapon != None && PrevWeapon != DesiredWeapon && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive') )
	{
		PrevWeapon.TryPutdown();
		
		PC.ClientMessage("putdown");
	}
	else
	{
		ChangedWeapon();
	}
}

simulated function ChangedWeapon()
{
	local Weapon OldWeapon;

	// Save current weapon as old weapon
	OldWeapon = Instigator.Weapon;
	
	// switch to Pending Weapon
	Instigator.Weapon = PendingWeapon;

	// Play any Weapon Switch Animations
	//Instigator.PlayWeaponSwitch(OldWeapon, PendingWeapon);

	// If we are going to an actual weapon, activate it.
	if( PendingWeapon != None )
	{
		// Setup the Weapon
		PendingWeapon.Instigator = Instigator;

		// Make some noise
		if( WorldInfo.Game != None )
		{
			Instigator.MakeNoise( 0.1, 'ChangedWeapon' );
		}

		// Activate the Weapon
		PendingWeapon.Activate();
		PendingWeapon = None;
	}

	// Notify of a weapon change
	if( Instigator.Controller != None )
	{
		Instigator.Controller.NotifyChangedWeapon(OldWeapon, Instigator.Weapon);
	}
}

reliable client function ClientSetCurrentWeapon(Weapon DesiredWeapon)
{
 SetPendingWeapon(DesiredWeapon);
}

simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	return Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
}

 //Handle AutoSwitching to a weapon
 
simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	return Super.AddInventory(NewItem, bDoNotActivate);
}

simulated function DiscardInventory()
{
 local Vehicle V;

 if (Role == ROLE_Authority)
 {
 Super.DiscardInventory();

 V = Vehicle(Owner);
 if (V != None && V.Driver != None && V.Driver.InvManager != None)
 {
 V.Driver.InvManager.DiscardInventory();
 }
 }
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
 if (Role==ROLE_Authority)
 {
 Super.RemoveFromInventory(ItemToRemove);
 }
}

  //Scans the inventory looking for any of type InvClass.&nbsp; If it finds it it returns it, other
 //it returns none.
 
function Inventory HasInventoryOfClass(class<Inventory> InvClass)
{
 local inventory inv;

 inv = InventoryChain;
 while(inv!=none)
 {
 if (Inv.Class==InvClass)
 return Inv;

 Inv = Inv.Inventory;
 }
 return none;
}

simulated function SwitchToPreviousWeapon()
{
 if ( PreviousWeapon!=none && PreviousWeapon != Pawn(Owner).Weapon )
 {
 PreviousWeapon.ClientWeaponSet(false);
 }
}

defaultproperties
{
 bMustHoldWeapon=true
 PendingFire(0)=0
 PendingFire(1)=0
}
