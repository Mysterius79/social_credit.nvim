local buf = vim.api.nvim_create_buf(false, true)
local win

vim.o.mousemoveevent = true
local mousemove_str = vim.api.nvim_replace_termcodes('<MouseMove>', false, false, true)

local social_credit_score = 800
local keys_in_last_500_ms = 0

local is_enabled = true
local window_open = false

vim.on_key(function(str)
    if is_enabled == true then
        if str == mousemove_str then
            if social_credit_score >= 10 then 
                social_credit_score = social_credit_score - 10
                CreateFloatingWindow()
                vim.defer_fn(CloseAllFloatingWindows, 1000)
                return
            end
        else
            if social_credit_score >= 1000 then
                AddToRecentKeys()
                social_credit_score = social_credit_score + keys_in_last_500_ms / 10
                return
            else
                AddToRecentKeys()
                social_credit_score = social_credit_score + keys_in_last_500_ms
            end
        end
    end
end)

function AddToRecentKeys()
    keys_in_last_500_ms = keys_in_last_500_ms + 1
    vim.defer_fn(RemoveFromRecentKeys, 500)
end

function RemoveFromRecentKeys()
    keys_in_last_500_ms = keys_in_last_500_ms - 1
    return
end

function ViewSocialCredit()
    if is_enabled == false then
        print("Enable the social credit system first to view your credits")
        return
    end

    if not pcall(test) and not window_open then
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

        window_open = true
        vim.defer_fn(CloseAllFloatingWindows, 1000)
    end
end

-- derived from: https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/
function CreateFloatingWindow()
    if not pcall(test) and not window_open then
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
        window_open = true
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
            vim.api.nvim_win_close(win, true)  -- do not force
            table.insert(closed_windows, win)
        end
    end
    window_open = false
end 

function DisableSocialCredit()
    if is_enabled == true then
        is_enabled = false
        print("Disabled Social Credit")
    end
end

function EnableSocialCredit()
    if is_enabled == false then
        is_enabled = true
        print("Enabled Social Credit")
    end
end

