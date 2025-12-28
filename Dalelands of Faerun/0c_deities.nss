/*//////////////////////////////////////////////////////////////////////////////
Script Name: 0c_deities
Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that sets a character to a specific deity.
 Param:
 sDeity - name of the deity to be changed to.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_character"

void main ()
{
    int nWeaponFocus, nWeaponProf, nWeaponSpec;
    object oPC = GetPCSpeaker();
    int nDeity = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "deity");
    if(nDeity > 0)
    {
        if(GetHasFeat(FEAT_WAR_DOMAIN_POWER, oPC))
        {
            // Check if the god has the war domain in its portfolio.
            int nWarDomain = StringToInt(Get2DAString("deities", "War_Domain", nDeity));
            if(nWarDomain)
            {
                nWeaponFocus = StringToInt(Get2DAString("deities", "Weapon_Focus", nDeity));
                if(GetHasFeat(nWeaponFocus, oPC)) NWNX_Creature_RemoveFeat(oPC, nWeaponFocus);
            }
        }
        int nLevel = GetLevelByClass (47/*Favored Soul*/, oPC);
        // Check for Weapon focus at level 3.
        if(nLevel >= 3)
        {
            nWeaponFocus = StringToInt(Get2DAString("deities", "Weapon_Focus", nDeity));
            if(nWeaponFocus > 0 && GetHasFeat(nWeaponFocus, oPC)) NWNX_Creature_RemoveFeat(oPC, nWeaponFocus);
        }
        // Check for Weapon focus at level 12.
        else if(nLevel >= 12)
        {
            nWeaponSpec = StringToInt(Get2DAString("deities", "Weapon_Spec", nDeity));
            if(nWeaponSpec > 0 && GetHasFeat(nWeaponSpec, oPC)) NWNX_Creature_RemoveFeat(oPC, nWeaponSpec);
        }
    }
    string sDiety = GetScriptParam("sDeity");
    SetDeity(oPC, sDiety);
    SetDeityInDatabase(oPC);
    CheckForFavoredSoulFeats(oPC);
    CheckForDomainFeats(oPC);
    SetCharacterEffectsToSkin(oPC);
    SetCharacterEffects(oPC);
}
