--Polygod Fragmentation
local s,id,o=GetID()
-- c210000028
function s.initial_effect(c)
	--[[
	[HOPT]
	Banish 1 Beast and 1 Machine “Polygod” non-Tuner monster, 1 each from your hand and Deck;
	Special Summon 1 “Polygod” Beast Tuner from your Deck in face-up Defense Position, but it cannot activate its effects.
	You cannot Special Summon monsters the turn you activate this card, except Level/Rank 4, 8, or 12 monsters.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.e1con)
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.e1limfil)
end
function s.e1limfil(c)
	local lvl=true
	local rnk=true

	if c:IsType(TYPE_XYZ) then
		rnk=(c:GetRank()==4
		or c:GetRank()==8
		or c:GetRank()==12)
	else
		lvl=(c:GetLevel()==4
		or c:GetLevel()==8
		or c:GetLevel()==12)
	end

	return (lvl and rnk)
end
function s.e1cstfil1(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsRace(RACE_BEAST+RACE_MACHINE)
	and not c:IsType(TYPE_TUNER)
	and c:IsAbleToRemove()
	and Duel.IsExistingMatchingCard(s.e1cstfil2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetRace())
end
function s.e1cstfil2(c,e,tp,r1)
	return c:IsSetCard(0xce1)
	and c:IsRace(RACE_BEAST+RACE_MACHINE)
	and not c:IsType(TYPE_TUNER)
	and c:IsAbleToRemove()
	and not c:IsRace(r1)
end
function s.e1sumfil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsRace(RACE_BEAST)
	and c:IsType(TYPE_TUNER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.e1lim(e,c)
	local lvl=true
	local rnk=true

	if c:IsType(TYPE_XYZ) then
		rnk=(c:GetRank()==4
		or c:GetRank()==8
		or c:GetRank()==12)
	else
		lvl=(c:GetLevel()==4
		or c:GetLevel()==8
		or c:GetLevel()==12)
	end

	return not (lvl and rnk)
end
function s.e1con(e,tp)
	return Duel.IsExistingMatchingCard(s.e1cstfil1,tp,LOCATION_DECK,0,1,nil,e,tp)
	and Duel.IsExistingMatchingCard(s.e1sumfil,tp,LOCATION_DECK,0,1,nil,e,tp)
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e1cstfil1,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	
	local e1b=Effect.CreateEffect(e:GetHandler())
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1b:SetReset(RESET_PHASE+PHASE_END)
	e1b:SetTargetRange(1,0)
	e1b:SetTarget(s.e1lim)
	Duel.RegisterEffect(e1b,tp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	
	local sg1=Duel.SelectMatchingCard(tp,s.e1cstfil1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sel1=sg1:GetFirst()

	local sg2=Duel.SelectMatchingCard(tp,s.e1cstfil2,tp,LOCATION_HAND,0,1,1,nil,e,tp,sel1:GetRace())
	local sel2=sg2:GetFirst()

	local sgf=Group.CreateGroup()
	sgf:AddCard(sel1)
	sgf:AddCard(sel2)

	Duel.Remove(sgf,POS_FACEUP,REASON_COST)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1sumfil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e1evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e1sumfil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			local e1b=Effect.CreateEffect(e:GetHandler())
			e1b:SetType(EFFECT_TYPE_SINGLE)
			e1b:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1b:SetCode(EFFECT_CANNOT_TRIGGER)
			e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1b)
		end
		Duel.SpecialSummonComplete()
	end
end