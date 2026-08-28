-- packui.nvim
-- A lazy.nvim-style dashboard for Neovim's built-in vim.pack plugin manager.
--
-- Usage:
--   require("packui").setup()   -- optional, accepts config overrides
--   :PackUI                     -- open the dashboard
--
-- Keymaps inside the dashboard (see config.keymaps to change them):
--   R        refresh / re-check all plugins for updates (async git fetch)
--   u        update the plugin under the cursor (opens vim.pack's native
--            confirmation tabpage so you can review the diff before writing)
--   U        update ALL plugins (same native confirmation flow)
--   x        remove the plugin under the cursor from disk (vim.pack.del)
--   <CR>/K   show recent commit log for the plugin under the cursor
--   q/<Esc>  close the dashboard

local M = {}

---------------------------------------------------------------------------
-- Config
---------------------------------------------------------------------------

local defaults = {
  border = "rounded",
  width = 0.82,
  height = 0.82,
  icons = {
    active = "●",
    inactive = "○",
    update = "↑",
    pinned = "",
    checking = "…",
  },
  keymaps = {
    close = { "q", "<Esc>" },
    refresh = "R",
    update_cursor = "u",
    update_all = "U",
    delete_cursor = "x",
    log = { "<CR>", "K" },
  },
}

local config = vim.deepcopy(defaults)

function M.setup(opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  vim.api.nvim_set_hl(0, "PackUIActive", { link = "DiagnosticOk", default = true })
  vim.api.nvim_set_hl(0, "PackUIInactive", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "PackUIUpdate", { link = "DiagnosticWarn", default = true })
  vim.api.nvim_set_hl(0, "PackUIPinned", { link = "DiagnosticHint", default = true })
  vim.api.nvim_set_hl(0, "PackUIName", { link = "Title", default = true })
  vim.api.nvim_set_hl(0, "PackUIDim", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "PackUIHeader", { link = "FloatTitle", default = true })
end

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("packui")

local state = {
  buf = nil,
  win = nil,
  plugins = {},       -- ordered list of plugin info tables
  line_of = {},        -- plugin name -> buffer line (1-indexed)
  name_of_line = {},   -- buffer line -> plugin name
}

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

-- Returns:
--   "explicit", <ref>   -- spec pins a branch/tag name we can fetch and diff
--   "detect"            -- spec has no version; ask git what's checked out
--   "skip"               -- semver range or similar, not handled here
local function tracking_kind(plugin)
  local version = plugin.spec.version
  if version == nil then
    return "detect"
  end
  if type(version) == "string" then
    return "explicit", version
  end
  return "skip"
end

local function load_plugins()
  local ok, plugins = pcall(vim.pack.get, nil, { info = true })
  if not ok then
    vim.notify("packui: " .. tostring(plugins), vim.log.levels.ERROR)
    return {}
  end
  table.sort(plugins, function(a, b)
    return a.spec.name:lower() < b.spec.name:lower()
  end)
  for _, p in ipairs(plugins) do
    p.update_status = "unknown" -- unknown | checking | up_to_date | update | pinned
  end
  return plugins
end

---------------------------------------------------------------------------
-- Async update checking (safe: fetch only, never merges/checks out)
---------------------------------------------------------------------------

-- Fetch `ref` from origin and diff local HEAD against what was fetched.
-- Never merges or checks anything out.
local function fetch_and_diff(plugin, ref, on_done)
  vim.system(
    { "git", "fetch", "--quiet", "origin", ref },
    { cwd = plugin.path, timeout = 15000 },
    vim.schedule_wrap(function(fetch_res)
      if fetch_res.code ~= 0 then
        -- Most common cause: `ref` is a raw commit SHA the server won't
        -- serve via `fetch <ref>` (uploadpack.allowReachableSHA1InWant is
        -- usually off) -- i.e. it's pinned to an exact commit.
        plugin.update_status = "pinned"
        on_done()
        return
      end
      vim.system(
        { "git", "rev-parse", "HEAD", "FETCH_HEAD" },
        { cwd = plugin.path, text = true, timeout = 5000 },
        vim.schedule_wrap(function(rp_res)
          if rp_res.code ~= 0 then
            plugin.update_status = "unknown"
            on_done()
            return
          end
          local lines = vim.split(rp_res.stdout or "", "\n", { trimempty = true })
          if #lines >= 2 and lines[1] ~= lines[2] then
            plugin.update_status = "update"
          else
            plugin.update_status = "up_to_date"
          end
          on_done()
        end)
      )
    end)
  )
end

local function check_plugin_update(plugin, on_done)
  local kind, explicit_ref = tracking_kind(plugin)

  if kind == "skip" then
    plugin.update_status = "pinned"
    on_done()
    return
  end

  plugin.update_status = "checking"

  if kind == "explicit" then
    fetch_and_diff(plugin, explicit_ref, on_done)
    return
  end

  -- kind == "detect": no version pinned in the spec, so find out what
  -- branch is actually checked out rather than guessing from plugin.branches
  -- (that list isn't guaranteed to be ordered with the default branch first).
  vim.system(
    { "git", "rev-parse", "--abbrev-ref", "HEAD" },
    { cwd = plugin.path, text = true, timeout = 5000 },
    vim.schedule_wrap(function(res)
      local branch = res.code == 0 and vim.trim(res.stdout or "") or nil
      if not branch or branch == "" or branch == "HEAD" then
        -- Detached HEAD: pinned to a specific commit, not a moving branch.
        plugin.update_status = "pinned"
        on_done()
        return
      end
      fetch_and_diff(plugin, branch, on_done)
    end)
  )
end

local function check_all_updates(plugins, on_progress)
  local remaining = #plugins
  if remaining == 0 then
    return
  end
  for _, plugin in ipairs(plugins) do
    check_plugin_update(plugin, function()
      remaining = remaining - 1
      on_progress()
    end)
  end
end

---------------------------------------------------------------------------
-- Rendering
---------------------------------------------------------------------------

local status_icon = {
  unknown = " ",
  checking = config.icons.checking,
  up_to_date = "✓",
  update = config.icons.update,
  pinned = config.icons.pinned,
}

local status_hl = {
  unknown = "PackUIDim",
  checking = "PackUIDim",
  up_to_date = "PackUIDim",
  update = "PackUIUpdate",
  pinned = "PackUIPinned",
}

local function version_label(plugin)
  local v = plugin.spec.version
  if v == nil then
    return (plugin.branches and plugin.branches[1]) or "default"
  elseif type(v) == "string" then
    return v
  else
    return "semver"
  end
end

local function render()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end

  local update_count = 0
  for _, p in ipairs(state.plugins) do
    if p.update_status == "update" then
      update_count = update_count + 1
    end
  end

  local lines = {}
  local highlights = {} -- { line, col_start, col_end, hl }
  state.line_of = {}
  state.name_of_line = {}

  local header = string.format(
    " packui — %d plugin%s managed by vim.pack",
    #state.plugins,
    #state.plugins == 1 and "" or "s"
  )
  if update_count > 0 then
    header = header .. string.format("  (%d update%s available)", update_count, update_count == 1 and "" or "s")
  end
  table.insert(lines, header)
  table.insert(lines, "")
  table.insert(highlights, { 1, 0, -1, "PackUIHeader" })

  table.insert(lines, "  R refresh   u update   U update-all   x remove   <CR> log   q close")
  table.insert(lines, "")
  table.insert(highlights, { 3, 0, -1, "PackUIDim" })

  for _, p in ipairs(state.plugins) do
    local line_no = #lines + 1
    local active_icon = p.active and config.icons.active or config.icons.inactive
    local active_hl = p.active and "PackUIActive" or "PackUIInactive"
    local status = status_icon[p.update_status] or " "
    local short_rev = p.rev and p.rev:sub(1, 8) or "?"

    local text = string.format(
      "  %s %-28s %-10s %-9s %s",
      active_icon,
      p.spec.name,
      version_label(p),
      short_rev,
      status
    )
    table.insert(lines, text)

    state.line_of[p.spec.name] = line_no
    state.name_of_line[line_no] = p.spec.name

    table.insert(highlights, { line_no, 2, 3, active_hl })
    table.insert(highlights, { line_no, 4, 4 + #p.spec.name, "PackUIName" })
    table.insert(highlights, { line_no, #text - 1, #text, status_hl[p.update_status] or "PackUIDim" })
  end

  if #state.plugins == 0 then
    table.insert(lines, "  No plugins found (vim.pack.get() returned nothing).")
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.buf, ns, h[4], h[1] - 1, h[2], h[3])
  end
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

local function plugin_under_cursor()
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  local name = state.name_of_line[line]
  if not name then
    return nil
  end
  for _, p in ipairs(state.plugins) do
    if p.spec.name == name then
      return p
    end
  end
  return nil
end

local function do_refresh()
  state.plugins = load_plugins()
  render()
  check_all_updates(state.plugins, render)
end

local function do_update_cursor()
  local p = plugin_under_cursor()
  if not p then
    return
  end
  M.close()
  vim.pack.update({ p.spec.name })
end

local function do_update_all()
  M.close()
  vim.pack.update()
end

local function do_delete_cursor()
  local p = plugin_under_cursor()
  if not p then
    return
  end
  local choice = vim.fn.confirm("Remove '" .. p.spec.name .. "' from disk?", "&Yes\n&No", 2)
  if choice ~= 1 then
    return
  end
  local ok, err = pcall(vim.pack.del, { p.spec.name })
  if not ok then
    vim.notify("packui: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  do_refresh()
end

local function do_show_log()
  local p = plugin_under_cursor()
  if not p then
    return
  end
  vim.system(
    { "git", "log", "-n", "12", "--pretty=format:%h  %ad  %s", "--date=short" },
    { cwd = p.path, text = true, timeout = 5000 },
    vim.schedule_wrap(function(res)
      local body = (res.stdout and res.stdout ~= "") and res.stdout or (res.stderr or "no log available")
      local log_lines = vim.split(body, "\n", { trimempty = true })
      table.insert(log_lines, 1, p.spec.name .. " — recent commits")
      table.insert(log_lines, 2, "")

      local width = math.min(90, math.floor(vim.o.columns * 0.7))
      local height = math.min(#log_lines + 2, math.floor(vim.o.lines * 0.6))
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = "wipe"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, log_lines)
      vim.bo[buf].modifiable = false
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = config.border,
        title = " log ",
        title_pos = "center",
        style = "minimal",
      })
      vim.api.nvim_win_set_hl_ns(win, ns)
      for _, lhs in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", lhs, "<cmd>close<CR>", { buffer = buf, nowait = true })
      end
    end)
  )
end

---------------------------------------------------------------------------
-- Window management
---------------------------------------------------------------------------

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

local function set_keymaps(buf)
  local function map(lhs_list, fn)
    if type(lhs_list) == "string" then
      lhs_list = { lhs_list }
    end
    for _, lhs in ipairs(lhs_list) do
      vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true })
    end
  end

  map(config.keymaps.close, M.close)
  map(config.keymaps.refresh, do_refresh)
  map(config.keymaps.update_cursor, do_update_cursor)
  map(config.keymaps.update_all, do_update_all)
  map(config.keymaps.delete_cursor, do_delete_cursor)
  map(config.keymaps.log, do_show_log)
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "packui"
  vim.bo[buf].modifiable = false

  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = config.border,
    title = " PackUI ",
    title_pos = "center",
    style = "minimal",
  })
  vim.api.nvim_win_set_hl_ns(win, ns)
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  state.buf = buf
  state.win = win

  set_keymaps(buf)
  do_refresh()
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

return M
