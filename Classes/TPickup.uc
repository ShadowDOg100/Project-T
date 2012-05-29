class TPickup extends Actor
        abstract;

// Light Environment
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

// Player
var TPawn Player;

// Replenish Ammo, Health, Armor
var int amount; // Final amount to replenish
var int restore; // Amount to be restored

// Weapon
var class<TWeapon> weapClass;
var TWeapon Weapon;
var int WeapSlot;
var int WeapSubClass;
var array<TWeapon> WeaponList;

// Tell what item
var string item;

// Message
var string message;

// Ammunition
var int ammo;
var int clipAmmo;

// Boolean
var bool bTouch;
var bool bShowHUD;

/** Weapons **/
// get weapon inventory slot
function int getWeapSlot()
{
	if (Weapon != none)
        {
                return Weapon.GetInventorySlot();
        }
}

// get weapon subclass
function int getWeapSubClass()
{
	if (Weapon != none)
	{
                return Weapon.GetWeaponSubClass();
        }
}

// get weapon ammo
function int getAmmo()
{
	if (Weapon != none)
	{
                return Weapon.GetAmmoCount();
        }
}

// get weapon clip
function int getClip()
{
	if (Weapon != none)
	{
                return Weapon.GetClipCount();
        }
}

/** Pawn **/
// get pawn health
function int getHealth()
{
        if (Player != none)
        {
                return Player.getHealth();
        }
}

// set pawn health
function setHealth(int value)
{
        if (Player != none)
        {
                if (value <= 100)
                {
                        Player.setHealth(value);
                }
                else
                {
                        Player.setHealth(100);
                }
        }
}

// get pawn armor
function int getArmor()
{
        if (Player != none)
        {
                return Player.getArmor();
        }
}

// set pawn armor
function setArmor(int value)
{
        if (Player != none)
        {
                if (value <= 100)
                {
                        Player.setArmor(value);
                }
                else
                {
                        Player.setArmor(100);
                }
        }
}

// Pickup Weapon or Item
simulated function Pickup()
{
        
        /*
                        case "WP":
                                num1 = GetWeapSlot();
		                num2 = GetWeapSubClass();
		                TP.GetWeaponList(WeaponList,true);
		                if(WeaponList[num1] != None)
		                {
			             if(WeaponList[num1].GetWeaponSubClass() == num2)
			             {
				            WeaponList[num1].AddStorageAmmo(getAmmo() + getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
			             else
			             {
				            //swap weapon
			             }
		                }
		                else
		                {
			             PC.ClientMessage("PickUp");
			             Inv = spawn(touchWeap);
			             if ( Inv != None )
			             {
				            PC.ClientMessage("PickUp");
				            TP.CreateInventory( touchWeap );
				            TP.GetWeaponList(WeaponList, true);
				            WeaponList[num1].SetAmmo(getAmmo());
				            WeaponList[num1].SetClip(getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
		                }
        */
}

defaultproperties
{
}