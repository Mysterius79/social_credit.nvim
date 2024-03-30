local buf = vim.api.nvim_create_buf(false, true)
local win

vim.o.mousemoveevent = true
local mousemove_str = vim.api.nvim_replace_termcodes('<MouseMove>', false, false, true)

local social_credit_score = 800
local keys_in_last_3_secs = 0

local is_enabled = true

vim.on_key(function(str)
    if enabled == true then
        if str == mousemove_str then
            if social_credit_score >= 10 then 
                social_credit_score = social_credit_score - 10
                CreateFloatingWindow()
                vim.defer_fn(CloseAllFloatingWindows, 1000)
                return
            end
        end

        if social_credit_score >= 1000 then
            AddToRecentKeys()
            social_credit_score = social_credit_score + keys_in_last_3_secs / 10
            return
        end
        AddToRecentKeys()
        social_credit_score = social_credit_score + keys_in_last_3_secs
    end
end)

function AddToRecentKeys()
    if keys_in_last_3_secs <= 3 then
        keys_in_last_3_secs = keys_in_last_3_secs + 1
        vim.defer_fn(RemoveFromRecentKeys, 3000)
    end
end

function RemoveFromRecentKeys()
    if keys_in_last_3_secs > 0 then
        keys_in_last_3_secs = keys_in_last_3_secs - 1
        return
    end
end

function ViewSocialCredit()
    if enabled == false then
        print("Enable the social credit system first to view your credits")
        return
    end

    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, {string.format("Your current social credit is: %d", social_credit_score)})

    local win_width = math.min(math.ceil(width / 4), 40)
    local win_height = 2

    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        style = 'minimal',
        row = math.ceil((height - win_height) / 1.1),
        col = width
    }

    win = vim.api.nvim_open_win(buf, 0, opts)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')

    vim.defer_fn(CloseAllFloatingWindows, 1000)
end

-- derived from: https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/
function CreateFloatingWindow()
    if not pcall(test) then
        local width = vim.api.nvim_get_option("columns")
        local height = vim.api.nvim_get_option("lines")

        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, {string.format("Reduced social credit score to: %d", social_credit_score)})

        local win_width = math.min(math.ceil(width / 4), 40)
        local win_height = 2

        local opts = {
            relative = "editor",
            width = win_width,
            height = win_height,
            style = 'minimal',
            row = math.ceil((height - win_height) / 1.1),
            col = width
        }

        win = vim.api.nvim_open_win(buf, 0, opts)
        vim.api.nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
    end
end

function test()
    vim.api.nvim_win_get_config(win)
end

-- stolen from: https://www.reddit.com/r/neovim/comments/skkwnd/comment/hvlwo91/
function CloseAllFloatingWindows()
    local closed_windows = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then  -- is_floating_window?
            vim.api.nvim_win_close(win, false)  -- do not force
            table.insert(closed_windows, win)
        end
    end
end 

function DisableSocialCredit()
    if enabled == true then
        enabled = false
        print("Disabled Social Credit")
    end
end

function EnableSocialCredit()
    if enabled == false then
        enabled = true
        print("Enabled Social Credit")
    end
end

