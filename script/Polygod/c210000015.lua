--Pyxis, The Polygod Compass
local s,id,o=GetID()
-- c210000015
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
	[HOPT]
	If this card is Normal Summoned: You can Special Summon 1 “Canis, The Polygod Wolf” from your Deck in Attack Position, then change this card’s battle position.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	During your Main Phase, while this card is in face-up Defense Position: You can target 1 “Polygod” Continuous Spell/Trap in your GY;
	change this card to Attack Position, and if you do, add that target to your hand.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,(id+1))
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c,e,tp)
	return c:IsCode(210000002)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2con(e,tp)
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_DECK,0,nil,e,tp)

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
	and g:GetCount()>=1
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
			Duel.BreakEffect()

			local c=e:GetHandler()
			local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
			if repl:GetCount()>0 then
				if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
					if c:IsAttackPos() then
						Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
					else
						Duel.ChangePosition(c,POS_FACEUP_ATTACK)
					end
				end
			else
				if c:IsAttackPos() then
					Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
				else
					Duel.ChangePosition(c,POS_FACEUP_ATTACK)
				end
			end
		end
	end
end
function s.e3fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_CONTINUOUS)
	and c:IsAbleToHand()
end
function s.e3con(e,tp)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_GRAVE,0,nil,e,tp)

	return e:GetHandler():IsDefensePos()
	and g:GetCount()>=1
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e3fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.e3evt(e)
	local c=e:GetHandler()
	if c:IsDefensePos() then
		local req=true

		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_ATTACK)
			end
		else
			req=Duel.ChangePosition(c,POS_FACEUP_ATTACK)>0
		end

		if req then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end