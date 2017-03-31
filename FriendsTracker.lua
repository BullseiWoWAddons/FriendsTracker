--SavedVariables: FriendsTracker_PerAccount
--SavedVariablesPerCharacter: FriendsTracker_PerCharacter
local addonname = ...
local ranonce
local frame = CreateFrame("FRAME")

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self,event,...)
	if event == "PLAYER_LOGIN" then
		frame:RegisterEvent("FRIENDLIST_UPDATE")
		frame:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	end
	
	-- oldschool Realm Friends
	FriendsTracker_PerCharacter = FriendsTracker_PerCharacter or {}
	local NumCurrentFriends = GetNumFriends()
	if not ranonce or (NumCurrentFriends ~= FriendsTracker_PerCharacter.NumOldFriends) then --if ranonce then only run this when the amount is not equal
		local CurrentFriends = {}
		for i = 1, NumCurrentFriends do
			local name = GetFriendInfo(i)
			if (name) then
				CurrentFriends[i] = name
			end
		end
		
		if FriendsTracker_PerCharacter.Friendlist then
			local tmp = {};
			for i=1, #CurrentFriends do
				tmp[CurrentFriends[i]]=1;
			end
			for i=1, #FriendsTracker_PerCharacter.Friendlist do
				if tmp[FriendsTracker_PerCharacter.Friendlist[i]] then
					tmp[FriendsTracker_PerCharacter.Friendlist[i]] = 3;
				else
					tmp[FriendsTracker_PerCharacter.Friendlist[i]] = 2;
				end
			end
			local allfound = true
			for name,v in pairs(tmp)do
				if v==1 then
					print("|cff0099ff"..addonname.."|r: |cFFFF0000Your new friend "..name.." is getting added to your list of existing friends.")
				elseif v==2 then
					print("|cff0099ff"..addonname.."|r: |cFFFF0000Your friend "..name.." is no longer on your friendlist.")
					if not FriendsTracker_PerCharacter.DeletedFriends then
						FriendsTracker_PerCharacter.DeletedFriends = {}
					end
					local weekday, month, day, year = CalendarGetDate() 
					FriendsTracker_PerCharacter.DeletedFriends[name] = {["month"] = month, ["day"] = day, ["year"] = year}
					allfound = false 
				end--  v==3: print(name,"found in both tables")
			end
			
			if allfound then 
				print("|cff0099ff"..addonname.."|r: |cFF00FF00All your friends still exist")
			else
				print("|cff0099ff"..addonname.."|r: |cFFFF0000Some friends have been removed")
			end		
		end
		FriendsTracker_PerCharacter.Friendlist = CurrentFriends 
		FriendsTracker_PerCharacter.NumOldFriends = NumCurrentFriends	
	end
	
	--Battle.net Friends
	FriendsTracker_PerAccount = FriendsTracker_PerAccount or {}
	local NumCurrentBnetFriends = BNGetNumFriends()
	if not ranonce or (NumCurrentBnetFriends ~= FriendsTracker_PerAccount.NumOldBnetFriends) then --if ranonce then only run this when the amount is not equal
		local CurrentBnetFriends = {}
		for i = 1, NumCurrentBnetFriends do
			local bnetIDAccount, accountName, battleTag = BNGetFriendInfo(i)
			if (battleTag) then
				CurrentBnetFriends[i] = battleTag
			end
		end
		
		if FriendsTracker_PerAccount.BnetFriendlist then
			local tmp = {};
			for i=1, #CurrentBnetFriends do
				tmp[CurrentBnetFriends[i]]=1;
			end
			for i=1, #FriendsTracker_PerAccount.BnetFriendlist do
				if tmp[FriendsTracker_PerAccount.BnetFriendlist[i]] then
					tmp[FriendsTracker_PerAccount.BnetFriendlist[i]] = 3;
				else
					tmp[FriendsTracker_PerAccount.BnetFriendlist[i]] = 2;
				end
			end
			local allfound = true
			for btag,v in pairs(tmp)do
				if v==1 then
					print("|cff0099ff"..addonname.."|r: |cFFFF0000Your new friend "..btag.." is getting added to your list of existing Battle.net friends.")
				elseif v==2 then
					print("|cff0099ff"..addonname.."|r: |cFFFF0000Your friend "..btag.." is no longer on your Battle.net friendlist.")
					if not FriendsTracker_PerAccount.DeletedBnetFriends then
						FriendsTracker_PerAccount.DeletedBnetFriends = {}
					end
					local weekday, month, day, year = CalendarGetDate() 
					FriendsTracker_PerAccount.DeletedBnetFriends[btag] = {["month"] = month, ["day"] = day, ["year"] = year}
					allfound = false
				end--  v==3: print(btag,"found in both tables")
			end
			
			if allfound then 
				print("|cff0099ff"..addonname.."|r: |cFF00FF00All your Battle.net friends still exist")
			else
				print("|cff0099ff"..addonname.."|r: |cFFFF0000Some Battle.net friends have been removed")
			end		
		end
		FriendsTracker_PerAccount.BnetFriendlist = CurrentBnetFriends 
		FriendsTracker_PerAccount.NumOldBnetFriends = NumCurrentBnetFriends	
	end
	ranonce = true
end)

local CALENDAR_FULLDATE_MONTH_NAMES = { --copied from Blizzard_Calendar.lua
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
}

local function Getdate(day, month, year)
	local monthName = CALENDAR_FULLDATE_MONTH_NAMES[month]
	return day, monthName, year
end

--Slash command
SLASH_FRIENDSTRACKER1 = "/friendstracker"
SLASH_FRIENDSTRACKER2 = "/FriendsTracker"
SlashCmdList.FRIENDSTRACKER = function(msg, editBox)
	msg = msg:lower()
	if msg == "deleted" then
		local day, monthName, year
		
		--Usual Friends
		print("|cff0099ff"..addonname.."|r: |cFFFF0000List of deleted Realm Friends:")
		if FriendsTracker_PerCharacter.DeletedFriends then
			for name, dateofdel in pairs(FriendsTracker_PerCharacter.DeletedFriends) do
				day, monthName, year = Getdate(dateofdel.day, dateofdel.month, dateofdel.year)
				print("|cff0099ff"..addonname.."|r: |cFFFF0000"..name..": Deletion detected on "..day..". "..monthName.." "..year)
			end
		else
			print("|cff0099ff"..addonname.."|r: There are no deleted Realm Friends")
		end
		
		--Battle.net Friends
		print("|cff0099ff"..addonname.."|r: |cFFFF0000List of deleted Battle.net Friends:")
		if FriendsTracker_PerAccount.DeletedBnetFriends then
			for battleTag, dateofdel in pairs(FriendsTracker_PerAccount.DeletedBnetFriends) do
				day, monthName, year = Getdate(dateofdel.day, dateofdel.month, dateofdel.year)
				print("|cff0099ff"..addonname.."|r: |cFFFF0000"..battleTag..": Deletion detected on "..day..". "..monthName.." "..year)
			end
		else
			print("|cff0099ff"..addonname.."|r: There are no deleted Battle.net Friends")
		end
		
	end
end