--Custos, The Polygod Guardian
local s,id,o=GetID()
-- c210000045
function s.initial_effect(c)
	-- 4 “Polygod” monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),4,4)
	c:EnableReviveLimit()
	--[[
	Once per turn, you can also Link Summon “Custos, The Polygod Guardian” to the Extra Monster Zone by
	returning 4 “Polygod” monsters from your banishment to the GY.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- You can only control 1 “Custos, The Polygod Guardian”.
	c:SetUniqueOnField(1,0,id)
	-- Cannot be destroyed by battle.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- If this card would be sent to the GY, banish it instead.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.e3con)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)

	if not s.global_check then
		s.global_check=true

		local e3b=Effect.GlobalEffect()
		e3b:SetType(EFFECT_TYPE_FIELD)
		e3b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e3b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e3b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e3b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e3b,0)
	end
	-- You take no battle damage from battles involving this card.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- Monsters this card points to are unaffected by other cards’ effects.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	--e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetTarget(s.e5tgt)
	e5:SetValue(s.e5fil)
	c:RegisterEffect(e5)
end
function s.e1fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	--and c:IsAbleToGraveAsCost()
end
function s.e1bfil(c,e,tp)
	return c:IsControler(tp)
end
function s.e1con(e,c)
	if c==nil then return true end
	local tp=c:GetControler()

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_REMOVED,0,nil)
	local g2=Duel.GetMatchingGroup(s.e1bfil,tp,LOCATION_EMZONE,0,nil,e,tp)

	return Duel.GetLocationCountFromEx(tp,tp,ec,c,0x60)>0
	and g:GetCount()>=4
	and g2:GetCount()==0
end
function s.e1evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()>=4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sel=Group.Select(g,tp,4,4,nil)
		Duel.SendtoGrave(sel,REASON_COST+REASON_RETURN)
	end
end
function s.e3con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e5tgt(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
	and c:IsType(TYPE_MONSTER)
end
function s.e5fil(e,te)
	return te:GetOwner()~=e:GetOwner()
end