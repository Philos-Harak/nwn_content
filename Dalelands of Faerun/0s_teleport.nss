/*////////////////////////////////////////////////////////////////////
 Script: 0s_teleport
 Programmer: Philos
//////////////////////////////////////////////////////////////////////
Teleport
Conjuration
Level: Wizard / Sorcerer 5, Travel 5
Components: V
Range: Personal
Target: Caster and touched targets
Duration: Instantaneous
Saving Throw: None
Spell Resistance: Yes (harmless)

This spell instantly transports you to a designated destination, which may be
as distant as 100 miles per caster level. Interplanar travel is not possible.
You may also bring one additional willing medium or smaller creature per three
caster levels (Any creatures within 5' that are in your party will be
teleported with you up to the maximum number starting with any familiars,
companions, and henchmen). A large creature counts as two medium creatures,
a huge creature counts as two large creatures and so forth.

    The more familiar you are with a location the better your chances of appearing
at the exact location. Below is a chart with the chances of appearing where
you want to teleport and a list of how familiar you can be of the locations.

Familiar - A civilized area you have set in the teleport menu.
Studied - An uncivilized area you have set in the teleport menu.
Unknown - Any area you are entering into the unknown section of the teleport menu.

Once a location is selected you will roll a destinition percentage, see the
chart below for your result chances.
Familiar Studied Unknown  Description
 01-97    01-94     -     On target.
 98-99    98-99   01-88   Off target.
  100      100    89-96   Similar area.
   -        -     97-100  Mishap

On target - You appear at the exact location.
Off target - You appear at a random location in the area.
Similar area - You appear in a random location near your target area.
Mishap - You and anyone else teleporting with you have gotten "scrambled".
         Each creature takes 1d10 magic damage, and reroll on the chart using
         1d20+80. Each time "Mishap" comes up, the creatures take more damage
         and continue to reroll until dead.
/*////////////////////////////////////////////////////////////////////
#include "0i_win_layout_pc"
#include "0i_spells"
#include "0i_area"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_TELEPORTATION;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oPlayer;
    if(GetIsCharacter(Spell.oCaster)) oPlayer = Spell.oCaster;
    else
    {
        object oMaster = GetMaster(Spell.oCaster);
        if(GetIsCharacter(oMaster)) oPlayer = oMaster;
        else return;
    }
    json jTArray = GetObjectDatabaseJson (oPlayer, CHARACTER_TABLE, "teleport");
    // Get the teleport location.
    int nSelected = JsonGetInt (JsonArrayGet (jTArray, 21));
    string sTeleport = JsonGetString (JsonArrayGet (jTArray, nSelected));
    // If we have not selected a location to teleport pull up the teleport window.
    if (sTeleport == "")
    {
        // Pass the spell being cast.
        SetLocalInt (Spell.oCaster, "0_Teleport_Spell", Spell.iSpellID);
        PopUpPlayerTeleportGUIPanel (oPlayer);
    }
    // We have selected a location to teleport to... lets get going!
    else
    {
        Teleport(oPlayer, sTeleport, Spell.iSpellID, Spell.iCasterLevel);
    }
}
