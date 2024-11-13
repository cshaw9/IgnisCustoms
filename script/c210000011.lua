--Fucus, The Polygod Drone
local s,id,o=GetID()
-- c210000011
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
	If a “Polygod” monster you control is destroyed by battle with an opponent’s attacking monster, while this card is in face-up Defense Position:
	You can target the attacking monster; destroy it,
	and if you do, change this card to Attack Position.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c,tp)
	local tg=Duel.GetAttacker()
	
	return c:IsSetCard(0xce1)
	and c:IsPreviousControler(tp)
	--and tg:IsControler(1-tp)
end
function s.e2con(e,tp,eg)
	return e:GetHandler():IsDefensePos() and eg:IsExists(s.e2fil,1,nil,tp)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()

	if chkc then
		return chkc==tg
	end
	if chk==0 then
		return tg:IsOnField()
		and tg:IsCanBeEffectTarget(e)
	end

	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e2evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			if c:IsDefensePos() then
				local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
				if repl:GetCount()>0 then
					if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
						Duel.ChangePosition(c,POS_FACEUP_ATTACK)
					end
				else
					Duel.ChangePosition(c,POS_FACEUP_ATTACK)
				end
			end
		end
	end
end