local isInit = false
local cFonts         = {"NumberFontNormal", "NumberFontNormalLarge", "NumberFontNormalHuge", "GameFontNormal", "GameFontNormalLarge", "GameFontNormalHuge", "ChatFontNormal", "QuestFont", "MailTextFontNormal", "QuestTitleFont"};
local iCurrentFont   = 10

local O = {};
O.CurrentFont = iCurrentFont;
O.SplashDuration = 15;
local OG = {}; -- Options global
if (O.SplashX == nil) then O.SplashX = 100; end
if (O.SplashY == nil) then O.SplashY = -100; end
if (O.CurrentFont == nil) then O.CurrentFont = 8; end
if (O.ColSplashFont == nil) then
    O.ColSplashFont = { };
    O.ColSplashFont.r = 1.0;
    O.ColSplashFont.g = 1.0;
    O.ColSplashFont.b = 1.0;                
end

-- Splash screen functions ---------------------------------------------------------------------------------------

function YouAreNotPrepared_ShowMessage(secondsVisible, msg)
    YouAreNotPreparedSplashFrame:Clear();
    YouAreNotPreparedSplashFrame:SetTimeVisible(secondsVisible);
    YouAreNotPreparedSplashFrame:AddMessage(msg, O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
    --YouAreNotPrepared_Splash_Show(secondsVisible)
end

function YouAreNotPrepared_Splash_Reset()
    YouAreNotPreparedSplashFrame:ClearAllPoints();
    YouAreNotPreparedSplashFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200);
end

function YouAreNotPrepared_Splash_Show(timeVisible)
    YouAreNotPrepared_Splash_ChangeFont(1);
    -- "Interface/DialogFrame/UI-DialogBox-Background"
    -- "Interface/Tooltips/UI-Tooltip-Background"
    YouAreNotPreparedSplashFrame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background"});
    YouAreNotPreparedSplashFrame:EnableMouse(true);
    YouAreNotPreparedSplashFrame:Show();
    if not timeVisible then timeVisible = 15 end
    YouAreNotPreparedSplashFrame:SetTimeVisible(timeVisible);
end

function YouAreNotPrepared_Splash_Hide()
  if (not isInit) then return; end 
  YouAreNotPrepared_Splash_Clear();
  YouAreNotPrepared_Splash_ChangePos();
  YouAreNotPreparedSplashFrame:SetBackdrop(nil);
  YouAreNotPreparedSplashFrame:EnableMouse(false);
  YouAreNotPreparedSplashFrame:SetFadeDuration(O.SplashDuration);
  YouAreNotPreparedSplashFrame:SetTimeVisible(O.SplashDuration);
end

function YouAreNotPrepared_Splash_Clear()
  YouAreNotPreparedSplashFrame:Clear();
end

function YouAreNotPrepared_Splash_ChangePos()
  local x, y = YouAreNotPreparedSplashFrame:GetLeft(), YouAreNotPreparedSplashFrame:GetTop() - UIParent:GetHeight();
  if (O) then
    O.SplashX = x;
    O.SplashY = y;
  end
end

function YouAreNotPrepared_Splash_UpdateFont(f)
  if (not cFonts[iCurrentFont]) then
    iCurrentFont = 1;
  end
  O.CurrentFont = iCurrentFont;
  if not f then return end
  f:ClearAllPoints();
  f:SetPoint("TOPLEFT", O.SplashX, O.SplashY);
  
  local fo = f:GetFontObject();
  local fName, fHeight, fFlags = _G[cFonts[iCurrentFont]]:GetFont();
  if (mode > 1 or O.CurrentFontSize == nil) then
    O.CurrentFontSize = fHeight;
  end
  fo:SetFont(fName, O.CurrentFontSize, fFlags);
  
  f:SetInsertMode("TOP");
  f:SetJustifyV("MIDDLE");
end

function YouAreNotPrepared_Splash_ChangeFont(mode)
  local f = YouAreNotPreparedSplashFrame;
  
  if (mode > 1) then
    YouAreNotPrepared_Splash_ChangePos();    
    iCurrentFont = iCurrentFont + 1;
  end
  if (not cFonts[iCurrentFont]) then
    iCurrentFont = 1;
  end
  O.CurrentFont = iCurrentFont;
  f:ClearAllPoints();
  f:SetPoint("TOPLEFT", O.SplashX, O.SplashY);
  
  local fo = f:GetFontObject();
  local fName, fHeight, fFlags = _G[cFonts[iCurrentFont]]:GetFont();
  if (mode > 1 or O.CurrentFontSize == nil) then
    O.CurrentFontSize = fHeight;
  end
  fo:SetFont(fName, O.CurrentFontSize, fFlags);
  
  f:SetInsertMode("TOP");
  f:SetJustifyV("MIDDLE");
  if (mode > 0) then
    local si = "";
    if (OG.SplashIcon) then 
      local n = O.SplashIconSize;
      if (n == nil or n <= 0) then
        n = O.CurrentFontSize;
      end
      si = string.format(" \124T%s:%d:%d:1:0\124t", "Interface\\Icons\\INV_Misc_QuestionMark", n, n) or "";
    else
      si = " BuffXYZ";
    end
    YouAreNotPrepared_Splash_Clear();
    if (OG.SplashMsgShort) then
      f:AddMessage(cFonts[iCurrentFont].." >"..si.."\ndrag'n'drop to move", O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
    else
      f:AddMessage(cFonts[iCurrentFont].." ".."needs"..si.."\ndrag'n'drop to move", O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
    end
  end
end

YouAreNotPrepared_Splash_UpdateFont(YouAreNotPreparedSplashFrame)

--YouAreNotPrepared_Splash_ChangeFont(0)
-- END Splash screen events

