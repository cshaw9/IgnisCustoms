--Polygod Entry Denial
local s,id,o=GetID()
-- c210000025
function s.initial_effect(c)
	-- If a “Polygod” monster(s) is banished by a card effect: Special Summon those monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPD]
	During your opponent's turn: You can banish this card from your hand;
	this turn, your opponent can only Summon 1 monster, except banished monsters,
	also, until the end of the next turn you cannot activate cards or effects, except “Polygod” cards.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,(id)+EFFECT_COUNT_CODE_DUEL)
	e2:SetHintTiming(0,TIMING_DRAW)
	e2:SetCondition(s.e2con)
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil(c,e,tp)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1con(e,tp,eg)
	return eg:IsExists(s.e1fil,1,nil,e,tp)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.e1fil,nil,e,tp)
	
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount()
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
function s.e1evt(e,tp,eg)
	local g=eg:Filter(s.e1fil,nil,e,tp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end

	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
function s.e2con(e,tp)
	return tp~=Duel.GetTurnPlayer()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0
	end

	local c=e:GetHandler()

	local e2b=Effect.CreateEffect(e:GetHandler())
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2b:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2b:SetTargetRange(1,0)
	e2b:SetValue(s.e2blim)
	e2b:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2b,tp)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.e2blim(e,re,tp)
	return not re:GetHandler():IsSetCard(0xce1)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local e2c1=Effect.CreateEffect(c)
	e2c1:SetType(EFFECT_TYPE_FIELD)
	e2c1:SetCode(EFFECT_CANNOT_SUMMON)
	e2c1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2c1:SetTargetRange(0,1)
	e2c1:SetTarget(s.e2clim)
	e2c1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2c1,tp)

	local e2c2=Effect.CreateEffect(c)
	e2c2:SetType(EFFECT_TYPE_FIELD)
	e2c2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e2c2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2c2:SetTargetRange(0,1)
	e2c2:SetTarget(s.e2clim)
	e2c2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2c2,tp)

	local e2c3=Effect.CreateEffect(c)
	e2c3:SetType(EFFECT_TYPE_FIELD)
	e2c3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2c3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2c3:SetTargetRange(0,1)
	e2c3:SetTarget(s.e2clim)
	e2c3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2c3,tp)

	local e2c4=Effect.CreateEffect(c)
	e2c4:SetType(EFFECT_TYPE_FIELD)
	e2c4:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e2c4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2c4:SetTargetRange(0,1)
	e2c4:SetValue(s.e2cval)
	e2c4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2c4,tp)
end
function s.e2csplim(e,c,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=1 or not c:IsLocation(LOCATION_REMOVED)
end
function s.e2clim(e,c,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=1
end
function s.e2cval(e,re,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	if t1+t2+t3>=1 then return 0 else return 1-t1-t2-t3 end
end