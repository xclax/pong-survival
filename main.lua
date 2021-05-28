push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong Survival')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT, 5, VIRTUAL_HEIGHT)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    timer = 0
    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if gameState == 'play' then
        timer = timer + dt
    end

    if gameState == 'start' then
        ball.dy = math.random(-50, 50)
        player2.dy = 0
        ball.dx = math.random(140, 200)

    elseif gameState == 'play' then

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.20
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            sounds['score']:play()
            gameState = 'done'

        end

    end

    -- keyboard controls
    if love.keyboard.isDown('up') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)

    if key == 'escape' then

        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then

            gameState = 'play'
        elseif gameState == 'done' then

            gameState = 'start'

            ball:reset()
            timer = 0

        end
    end
end

function love.draw()

    push:start()

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    if gameState == 'start' then

        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong Survival!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Survive!', 0, 10, VIRTUAL_WIDTH, 'center')
        displayTimer()
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('End of Game!  ' .. 'Your time: ' .. math.floor(timer) .. ' seconds', 0, 10, VIRTUAL_WIDTH,
            'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    push:finish()
end

function displayTimer()
    love.graphics.setFont(scoreFont)
    love.graphics.print(math.floor(timer), VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 3)
end

