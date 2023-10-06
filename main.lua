require 'lib.love-compat'

Object    = require 'lib.classic'
gamestate = require 'lib.gamestate'
bump      = require 'lib.bump'
util      = require 'lib.util'
anim8     = require 'lib.anim8'
scaler    = require 'lib.scaler'
flux      = require 'lib.flux'
timer     = require 'lib.timer'
signals   = require 'lib.signals'

require 'objects.GameObject'
require 'objects.Player'
require 'objects.Shuriken'
require 'objects.Bomb'
require 'objects.Controller'
require 'objects.KeyboardController'
require 'objects.JoystickController'
require 'objects.AIController'
require 'objects.Map'
require 'objects.Countdown'

require 'states.Gameplay'
require 'states.Menu'
require 'states.Paused'

function love.load()
	love.graphics.setDefaultFilter('linear', 'nearest')

	local image = love.graphics.newImage
	local font = love.graphics.newFont
	local sound = love.audio.newSource
	local mk = 'fonts/Mario-Kart-DS.ttf'

	Images = {
		ninja = image 'images/ninja.png',
		ninjaDead = image 'images/ninja_dead.png',
		background = image 'images/background_scaled.png',
		shuriken = image 'images/shuriken.png',
		ground = image 'images/ground.png',
		logo = image 'images/logo.png',
		bomb = image 'images/bomb.png',

		joystickControls = image 'images/joystick_controls.png',
		p1keyboardControls = image 'images/keyboard_controls_p1.png',
		p2keyboardControls = image 'images/keyboard_controls_p2.png',
	}

	Fonts = {
		-- title = font('fonts/Mario-Kart-DS.ttf', 48),
		normal = font(mk, 32),
		health = font(mk, 16),
		countdown = font(mk, 120),
		endgame = font(mk, 72),
	}


	Sounds = {
		select = sound('sounds/select.wav', "static"),
		ding = sound('sounds/ding.wav', "static"),
		roundStart = sound('sounds/round_start.wav', "static"),
		jump = sound('sounds/jump.wav', "static"),
		hurt = sound('sounds/hurt.wav', "static"),
		bombBounce = sound('sounds/bomb_bounce.wav', "static"),
		explosion = sound('sounds/explosion.wav', "static"),
		died = sound('sounds/died.wav', "static"),
		throw = sound('sounds/throw.wav', "static"),
	}

	GameTime = 0

	scaler.setScale(2)

	gamestate.registerEvents()
	gamestate.switch(Menu)
end

function love.update(dt)
	if gamestate.current() ~= Paused then
		GameTime = GameTime + dt
	end
end
