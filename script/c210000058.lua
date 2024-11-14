-- Rainbow Realm Reconstruction
local s,id,o=GetID()
-- c210000058
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control no monsters: Place 1 “Rainbow Realm of Doom” from your Deck or GY face-up in your Field Zone.
	While that card is in the Field Zone, it cannot be banished or shuffled into the Deck by card effects.
	You cannot Summon/Set monsters the turn you activate this effect.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	aux.GlobalCheck(s,function()
		local eg1=Effect.CreateEffect(c)
		eg1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		eg1:SetCode(EVENT_MSET)
		eg1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
		end)
		Duel.RegisterEffect(eg1,0)

		local eg2=eg1:Clone()
		eg2:SetCode(EVENT_SUMMON)
		Duel.RegisterEffect(eg2,0)

		local eg3=eg1:Clone()
		eg3:SetCode(EVENT_SPSUMMON)
		Duel.RegisterEffect(eg3,0)

		local eg4=eg1:Clone()
		eg4:SetCode(EVENT_FLIP_SUMMON)
		Duel.RegisterEffect(eg4,0)
	end)
	--[[
	[HOPT]
	During your opponent’s Battle Phase: You can banish this card from your GY;
	you take no battle damage for the rest of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,(id+1))
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetCondition(s.e2con)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and not Duel.HasFlagEffect(tp,id)
end
function s.e1fil(c,tp)
	return c:IsCode(210000046)
	and not c:IsForbidden()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e1fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	local e1a1=Effect.CreateEffect(c)
	e1a1:SetType(EFFECT_TYPE_FIELD)
	e1a1:SetCode(EFFECT_CANNOT_SUMMON)
	e1a1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a1:SetTargetRange(1,0)
	e1a1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1a1,tp)

	local e1a2=e1a1:Clone()
	e1a2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e1a2,tp)

	local e1a3=e1a1:Clone()
	e1a3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e1a3,tp)

	local e1a4=e1a1:Clone()
	e1a4:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e1a4,tp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e1fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
			local e1b1=Effect.CreateEffect(c)
			e1b1:SetType(EFFECT_TYPE_FIELD)
			e1b1:SetCode(EFFECT_CANNOT_REMOVE)
			e1b1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1b1:SetRange(LOCATION_FZONE)
			e1b1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
			e1b1:SetValue(1)
			e1b1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1b1,true)

			local e1b2=e1b1:Clone()
			e1b2:SetCode(EFFECT_CANNOT_TO_DECK)
			tc:RegisterEffect(e1b2,true)
		end
	end
end
function s.e2con(e,tp)
	return (Duel.GetCurrentPhase()==PHASE_BATTLE_START or Duel.IsBattlePhase())
	and Duel.IsTurnPlayer(1-tp)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	e2a:SetValue(1)
	e2a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2a,tp)

	local e2b=Effect.CreateEffect(c)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e2b:SetReset(RESET_PHASE|PHASE_END)
	e2b:SetTargetRange(1,0)
	Duel.RegisterEffect(e2b,tp)
end