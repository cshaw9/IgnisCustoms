-- Rainbow Realm Contortion
local s,id,o=GetID()
-- c210000054
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control no monsters:
	Place 1 “Area” Continuous Trap with a different name from the cards you control from your hand, Deck, or GY face-up on the field.
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
	During the Main Phase: You can banish this card from your GY;
	you take no effect damage for the rest of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,(id+1))
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and not Duel.HasFlagEffect(tp,id)
end
function s.e1fil(c,tp)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsForbidden()
	and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local z=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then z=z-1 end

	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e1fil),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		and z>0
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

	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e1fil),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local e2a=Effect.CreateEffect(e:GetHandler())
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CHANGE_DAMAGE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	e2a:SetValue(s.e2val)
	e2a:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2a,tp)

	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2b,tp)
end
function s.e2val(e,re,val,r)
	if (r&REASON_EFFECT)~=0 then
		return 0
	else
		return val
	end
end