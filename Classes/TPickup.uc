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
var int ammo;
var int clipAmmo;

// Tell what item
var string item;

// Message
var string message;

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

// Player touches pickup actor
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local PlayerController PC;

        PC = PlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
                WorldInfo.Game.BroadCast(Player,"Item touched");
                if (bShowHUD)
                {
                        // show pickup hud
                }
        }
}

// Player untouches pickup actor
event UnTouch(Actor Other)
{
        WorldInfo.Game.BroadCast(Player,"Item untouched");
        bTouch = false;
        bShowHUD = false;
        Player = none;
        Weapon = none;
        WeapSlot = 0;
        WeapSubClass = 0;
}

// Player picks up weapon
simulated function PickupWeap()
{
        local Inventory Inv;

        // PlaySound()
        Player.GetWeaponList(WeaponList,true);
        if(WeaponList[WeapSlot] != None)
	{
		if(WeaponList[WeapSlot].GetWeaponSubClass() == WeapSubClass)
		{
			WeaponList[WeapSlot].AddStorageAmmo(getAmmo() + getClip());
			return;
		}
		else
		{
			//swap weapon
		}
	}
	else
	{
                Inv = spawn(weapClass);
                if (Inv != none)
                {
			Player.CreateInventory(weapClass);
			Player.GetWeaponList(WeaponList, true);
			WeaponList[WeapSlot].SetAmmo(getAmmo());
			WeaponList[WeapSlot].SetClip(getClip());
		}
	}
	
	bTouch = false;
        Destroy();
}

defaultproperties
{
}