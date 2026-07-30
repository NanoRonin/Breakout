state = "load"
love.window.setTitle("Breakout")

function love.load()
    paddle = {}
    ball = {}
    rectangles = {}

    font = love.graphics.newFont("germainiaFont.ttf", 25)
    resetGame()
end

function love.update(dt)
    playerImage = love.graphics.newImage("heart.png")

    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and paddle.x > 0 then
        paddle.x = paddle.x - paddle.speed * dt
        if state == "load" then
            ball.x = ball.x - paddle.speed * dt
        end
    elseif (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and paddle.x < love.graphics.getWidth() - paddle.w then
        paddle.x = paddle.x + paddle.speed * dt
        if state == "load" then
            ball.x = ball.x + paddle.speed * dt
        end
    end

    ball.x = ball.x + ball.vx * ball.speed * dt
    ball.y = ball.y + ball.vy * ball.speed * dt

    if ball.x < 0 or ball.x > love.graphics.getWidth() - ball.r then
        ball.vx = -1 * ball.vx
    end

    if ball.y < 0 then
        ball.vy = -1 * ball.vy
    end

    if ball.y > love.graphics.getHeight() - ball.r then
        lives = lives - 1
        state = "load"

        setGame()
    end

    for i = 1, #rectangles do
        if isAllEmpty(rectangles) then
            setRectangles()
            setGame()
        end
        for j = #rectangles[i], 1, -1 do
            local rect = rectangles[i][j]

            if rect then
                if checkCollision(rect.x, rect.y, rect.w, rect.h, ball.x, ball.y, ball.r, ball.r) then
                    table.remove(rectangles[i], j)
                    ball.vy = -ball.vy
                    score = score + 1
                end
            end
        end
    end

    if checkCollision(ball.x, ball.y, ball.r, ball.r, paddle.x, paddle.y, paddle.w, paddle.h) then
        ball.y = paddle.y - ball.r
        ball.vy = -1 * ball.vy
    end
end

function love.draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.w, paddle.h)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.r, ball.r)
    love.graphics.printf(score, 10, 10, love.graphics.getWidth(), "center")

    for i = 1, #rectangles do
        for j = 1, #rectangles[i] do
            local rect = rectangles[i][j]

            love.graphics.setColor(rect.color[1], rect.color[2], rect.color[3])
            love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
        end
    end

    love.graphics.setColor(1, 1, 1)
    if lives == 3 then
        love.graphics.draw(playerImage, 0, 0)
        love.graphics.draw(playerImage, 32, 0)
        love.graphics.draw(playerImage, 64, 0)
    elseif lives == 2 then
        love.graphics.draw(playerImage, 0, 0)
        love.graphics.draw(playerImage, 32, 0)
    elseif lives == 1 then
        love.graphics.draw(playerImage, 0, 0)
    else
        resetGame()
    end
end

function resetGame()
    lives = 3
    score = 0
    setGame()
    setRectangles()
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function love.keypressed(key)
    if state == "load" and key == "space" then
        state = "game"
        ball.vx = love.math.random(0, 1) * 2 - 1
        ball.vy = -1
    end
end

function setGame()
    paddle.w = 175
    paddle.h = 15
    paddle.x = love.graphics.getWidth()/2 - paddle.w/2
    paddle.y = 550
    paddle.speed = 250

    ball.r = 16
    ball.x = love.graphics.getWidth()/2 - ball.r/2
    ball.y = 450
    ball.vx = 0 --love.math.random(0, 1) * 2 - 1
    ball.vy = 0 --love.math.random(0, 1) * 2 - 1
    ball.speed = 200
end

function setRectangles()
    for i = 1, 5 do
        rectangles[i] = {}
        for j = 1, 4 do
            rectangles[i][j] = {
                x =  (i - 1) * 160 + 20,
                y = j * 45,
                w = 120,
                h = 12,
            }

            if j == 1 then rectangles[i][j].color = {1, 0, 0}       -- Red
            elseif j == 2 then rectangles[i][j].color = {0, 1, 0}   -- Green
            elseif j == 3 then rectangles[i][j].color = {0, 0, 1}   -- Blue
            elseif j == 4 then rectangles[i][j].color = {1, 0, 1}   -- Purple
            end
        end
    end
end

function isAllEmpty(rects)
    if #rects == 0 then return true end -- Main table is empty
    
    for i = 1, #rects do
        if #rects[i] > 0 then
            return false -- Found a sub-table with rectangles
        end
    end
    return true -- All sub-tables are empty
end