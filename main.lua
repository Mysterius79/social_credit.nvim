local buf = vim.api.nvim_create_buf(false, true)
local win

vim.o.mousemoveevent = true

local mousemove_str = vim.api.nvim_replace_termcodes('<MouseMove>', false, false, true)

local social_credit_score = 800

local keys_in_last_3_secs = 0

vim.on_key(function(str)
    if str == mousemove_str then
        if social_credit_score >= 10 then 
            social_credit_score = social_credit_score - 10
            CreateFloatingWindow()
            vim.defer_fn(CloseAllFloatingWindows, 1000)
            -- vim.wait(1000)
            return
        end
    end
    AddToRecentKeys()
    social_credit_score = social_credit_score + keys_in_last_3_secs
end)

function AddToRecentKeys()
    keys_in_last_3_secs = keys_in_last_3_secs + 1
    vim.defer_fn(RemoveFromRecentKeys, 3000)
end

function RemoveFromRecentKeys()
    keys_in_last_3_secs = keys_in_last_3_secs - 1
end

-- derived from: https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/
function CreateFloatingWindow()
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

