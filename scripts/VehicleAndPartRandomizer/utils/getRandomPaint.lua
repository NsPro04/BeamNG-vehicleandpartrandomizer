local roundNear, math = roundNear, math

local function getRandomPaint()
	return {
		baseColor = {
			roundNear(math.random()  , 0.001),
			roundNear(math.random()  , 0.001),
			roundNear(math.random()  , 0.001),
			roundNear(math.random()*2, 0.001)
		},
		clearcoat          = roundNear(math.random(), 0.001),
		clearcoatRoughness = roundNear(math.random(), 0.001),
		metallic           = roundNear(math.random(), 0.001),
		roughness          = roundNear(math.random(), 0.001)
	}
end

return getRandomPaint