frost = LibStub("AceAddon-3.0"):NewAddon("frost", "AceConsole-3.0", "AceEvent-3.0")

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function frost:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: frost-2.0.0")

    spells = {  }
    spells["Frost Strike"] =            {r = 1 , g = 0 , b = 0}  
    spells["Howling Blast"] =           {r = 2 , g = 0 , b = 0}
    spells["Soul Reaper"] =             {r = 4 , g = 0 , b = 0}
    spells["Plague Strike"] =           {r = 8 , g = 0 , b = 0}
    spells["Obliterate"] =              {r = 16 , g = 0 , b = 0}
    spells["Rune Tap"] =                {r = 32 , g = 0 , b = 0}
    spells["Runic Corruption"] =        {r = 64 , g = 0 , b = 0}
    spells["Runic Empowerment"] =       {r = 128 , g = 0 , b = 0}
    spells["Horn of Winter"] =          {r = 0 , g = 1 , b = 0}
    spells["Outbreak"] =                {r = 0 , g = 2 , b = 0} 
    spells["Pillar of Frost"] =         {r = 0 , g = 4 , b = 0}
    spells["Empower Rune Weapon"] =     {r = 0 , g = 8 , b = 0}
    spells["Raise Dead"] =              {r = 0 , g = 16 , b = 0}

end

function frost:OnEnable()
    square_size = 15
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetWidth( square_size * 2 )
    f:SetHeight( square_size )
    f:SetPoint( "TOPLEFT" , square_size * 2 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( square_size )
    self.two:SetHeight( square_size )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 1 , 1 , 1 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , square_size , 0)
    self.three:SetWidth( square_size )
    self.three:SetHeight( square_size )
    self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.three:SetStatusBarColor( 1 , 1 , 1 )
    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    --self:RegisterEvent("CHAT_MSG_WHISPER")
end

function frost:OnDisable()
    -- Called when the addon is disabled
end

function canCastNow(inSpell)
    local start, duration, enable
    local usable, noRage = IsUsableSpell( inSpell )
        if usable == true then
            start, duration, enable = GetSpellCooldown( inSpell )
            if start == 0 then
                return true , 0
            end
        else
            return false , 0
        end
    return false , (start+duration - GetTime())
end

function frost:ACTIONBAR_UPDATE_COOLDOWN()
end

function frost:COMBAT_LOG_EVENT_UNFILTERED()
    local red = 0
    local green = 0
    local blue = 0
    local nextCast = {}
    local noSpell =  { r = 0 , g = 0 , b = 0 } 
    nextCast = noSpell
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);   

    local horn, hornrank, hornicon, horncount, horndebuffType, hornduration, hornexpirationTime, hornisMine, hornisStealable  = UnitBuff("player","Horn of Winter");   
    how, howcooldown = canCastNow( "Horn of Winter" )
    if how == true and horn == nil then
        nextCast = spells["Horn of Winter"]
    end
    
    -- are we in combat
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
        rp = UnitMana("player")
        th = UnitHealth("target")
        thm = UnitHealthMax("target")
        thp = th*100/thm

        runeOneStart, runeOneDuration, runeOne = GetRuneCooldown(1)
        runeTwoStart, runeTwoDuration, runeTwo = GetRuneCooldown(2)
        runeThreeStart, runeThreeDuration, runeThree = GetRuneCooldown(3)
        runeFourStart, runeFourDuration, runeFour = GetRuneCooldown(4)
        runeFiveStart, runeFiveDuration, runeFive = GetRuneCooldown(5)
        runeSixStart, runeSixDuration, runeSix = GetRuneCooldown(6)

		local ff, ffrank, fficon, ffcount, ffdebuffType, ffduration, ffexpirationTime, ffisMine, ffisStealable  = UnitDebuff("target","Frost Fever");
        local bp, bprank, bpicon, bpcount, bpdebuffType, bpduration, bpexpirationTime, bpisMine, bpisStealable  = UnitDebuff("target","Blood Plague");

        fs, fscooldown = canCastNow("Frost Strike")
        if fs == true and rp > 40 then
            nextCast = spells["Frost Strike"]
        end
        


        rimebuff, rimerank, rimeicon, rimecount = UnitBuff( "player" , "Freezing Fog")
        if rimebuff ~= nil then
            hb, hbcooldown = canCastNow( "Howling Blast")
            if hb == true then
                nextCast = spells["Howling Blast"]
            end
        end

        ob, obcooldown = canCastNow( "Obliterate")
        kmbuff, kmrank, kmicon, kmcount = UnitBuff( "player" , "Killing Machine")
        if ob == true then
            if kmbuff ~= nil then
                nextCast = spells["Obliterate"]
            end
            if runeOne == true and runeTwo == true and runeThree == true and runeFour == true and runeFive == true and runeSix == true then
                nextCast = spells["Obliterate"]
            end
        end

        pof, pofcooldown = canCastNow("Pillar of Frost")
        if pof == true then
            nextCast = spells["Pillar of Frost"]
        end

        erw, erwcooldown = canCastNow("Empower Rune Weapon")
        if erw == true then
            nextCast = spells["Empower Rune Weapon"]
        end

        rd, rdcooldown = canCastNow("Raise Dead")
        if rd == true then
            nextCast = spells["Raise Dead"]
        end

        howlingblast , howlingblastcooldown = canCastNow("Howling Blast")
        if ff ~= nil and ffisMine == "player" then
            -- self:Print("Frost fever detected")
            if ffexpirationTime then
                ffexpirein = ffexpirationTime - GetTime();
            end
            if ffexpirein > 0 and ffexpirein < 1 then
                
                if howlingblast == true then
                    nextCast = spells["Howling Blast"]
                end
            end
        else
            if howlingblast == true then
                nextCast = spells["Howling Blast"]
            end
        end

        plagueStrike , plagueStrikecooldown = canCastNow("Plague Strike")
        
        if bp ~= nil and bpisMine == "player" then
            if bpexpirationTime then
                bpexpirein = bpexpirationTime - GetTime();
            end
            if bpexpirein > 0 and bpexpirein < 1 then
                if plagueStrike == true then
                    nextCast = spells["Plague Strike"]
                end
            end
        else
            if plagueStrike == true then
                nextCast = spells["Plague Strike"]
            end
        end  

        if ff == nil and bp == nil then
            outb, outbcooldown = canCastNow("Outbreak")
            if outb == true then
                nextCast = spells["Outbreak"]
            end
        end

        if thp < 35 then
            sr, srcooldown = canCastNow("Soul Reaper")
            if sr == true then
                nextCast = spells["Soul Reaper"]
            end
        end
    end




    if nextCast ~= "none" then
        --;,dw;,self:Print( nextCast )
    end

    red = red + nextCast["r"]
    green = green + nextCast["g"]
    blue = blue + nextCast["b"]

    --self:Print( red , green , blue )
    self.two:SetStatusBarColor(red/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, 127/255, blue/255 );
end