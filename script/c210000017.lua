--Lyrae, The Polygod Lyre
local s,id,o=GetID()
-- c210000017
function s.initial_effect(c)
	-- If this card would be sent to the GY, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.e1con)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)

	if not s.global_check then
		s.global_check=true

		local e1b=Effect.GlobalEffect()
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e1b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e1b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1b,0)
	end
	--[[
	You can discard this card; add 1 “Polyworld” from your Deck to your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is banished, except by its own effect, while you control a Warrior or Dragon “Polygod” monster:
	You can equip this card to 1 Warrior or Dragon “Polygod” monster you control.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	A monster equipped with this card gains the following effect.
	• At the start of the Damage Step, if this card attacks: You can make this card’s ATK become double its current ATK, during damage calculation only,
	also, neither player takes any battle damage from this battle.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.e4con)
	e4:SetOperation(s.e4evt)
	
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4b:SetRange(LOCATION_SZONE)
	e4b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4b:SetTarget(s.e4btgt)
	e4b:SetLabelObject(e4)
	c:RegisterEffect(e4b)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c)
	return c:IsCode(210000020)
	and c:IsAbleToHand()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsDiscardable()
	end
	
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	local tg=Duel.GetFirstMatchingCard(s.e2fil,tp,LOCATION_DECK,0,nil)
	if tg then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
function s.e3fil(c)
	return c:IsSetCard(0xce1)
	and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_DRAGON))
	and c:IsFaceup()
end
function s.e3con(e,tp,eg,ep,ev,re)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_MZONE,0,nil,e,tp)

	return g:GetCount()>=1
	and (re and not re:GetHandler():IsCode(id))
	and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_MZONE,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	
	if g:GetCount()>0 then
		local c=e:GetHandler()
		local tc=g:GetFirst()
		
		if Duel.Equip(tp,c,tc) then
			local e3b=Effect.CreateEffect(tc)
			e3b:SetType(EFFECT_TYPE_SINGLE)
			e3b:SetCode(EFFECT_EQUIP_LIMIT)
			e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3b:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3b:SetValue(s.e3blim)
			c:RegisterEffect(e3b)
		end
	end
end
function s.e3blim(e,c)
	return e:GetOwner()==c
end
function s.e4con(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.e4evt(e)
	local c=e:GetHandler()

	local atk=c:GetAttack()*2

	local e4c1=Effect.CreateEffect(c)
	e4c1:SetType(EFFECT_TYPE_SINGLE)
	e4c1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4c1:SetRange(LOCATION_MZONE)
	e4c1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4c1:SetValue(atk)
	e4c1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e4c1)
	
	local e4c2=Effect.CreateEffect(c)
	e4c2:SetType(EFFECT_TYPE_SINGLE)
	e4c2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e4c2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e4c2)
end
function s.e4btgt(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.e4c1con(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end