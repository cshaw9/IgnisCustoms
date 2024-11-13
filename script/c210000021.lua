--Polygod Caretaker's Potion
local s,id,o=GetID()
-- c210000021
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Each time a “Polygod” monster(s) is banished, gain 500 LP for each.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	-- Each time a “Polygod” monster(s) changes its battle position, gain 500 LP.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	-- If this card would be sent to the GY, banish it instead.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(s.e4con)
	e4:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e4)

	if not s.global_check then
		s.global_check=true

		local e4b=Effect.GlobalEffect()
		e4b:SetType(EFFECT_TYPE_FIELD)
		e4b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e4b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e4b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e4b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e4b,0)
	end
end
function s.e2fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
end
function s.e2con(e,tp,eg)
	return eg:Filter(s.e2fil, nil):GetCount()>=1
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local ct=eg:Filter(s.e2fil, nil):GetCount()
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ct*500)
end
function s.e2evt(e)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
function s.e3fil(c)
	return c:IsSetCard(0xce1)
end
function s.e3con(e,tp,eg)
	return eg:Filter(s.e2fil, nil):GetCount()>=1
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local ct=eg:Filter(s.e2fil, nil):GetCount()
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ct*500)
end
function s.e3evt(e)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
function s.e4con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end