local function create_para_note()
  local options = {
    { name = "Project", folder = "Project", template = "project-template" },
    { name = "Area", folder = "Area", template = "area-template" },
    { name = "Resource", folder = "Resource", template = "resource-template" },
  }

  vim.ui.select(options, {
    prompt = "Select note type:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      vim.ui.input({ prompt = "Note name: " }, function(note_name)
        if note_name and note_name ~= "" then
          local client = require("obsidian").get_client()
          local note = client:create_note({
            title = note_name,
            dir = choice.folder,
            template = choice.template,
          })
          client:open_note(note)
        end
      end)
    end
  end)
end

local function move_to_archive()
  local client = require("obsidian").get_client()
  local note = client:current_note()

  if not note then
    vim.notify("No Obsidian note in current buffer", vim.log.levels.WARN)
    return
  end

  local filename = note.path.name

  -- Create archive directory if it doesn't exist
  local archive_dir = client.dir / "Archive"
  archive_dir:mkdir({ parents = true, exist_ok = true })

  -- Calculate new path
  local new_path = archive_dir / filename
  local current_path = note.path

  -- Move the file using filesystem operations
  local success, err = pcall(function()
    vim.uv.fs_rename(tostring(current_path), tostring(new_path))
  end)

  if success then
    -- Close current buffer
    vim.cmd("bdelete!")

    -- Open the moved file
    vim.cmd("edit " .. tostring(new_path))

    vim.notify("Moved to archive: " .. filename, vim.log.levels.INFO)
  else
    vim.notify("Failed to move file: " .. (err or "unknown error"), vim.log.levels.ERROR)
  end
end

local prefix = "<leader>o"

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    keys = {
      { prefix .. "g", "<cmd>ObsidianSearch<CR>", desc = "Grep" },
      { "<leader>so", "<cmd>ObsidianSearch<CR>", desc = "Obsidian Grep" },
      { prefix .. "<space>", "<cmd>ObsidianQuickSwitch<CR>", desc = "Find Files" },
      { prefix .. "d", "<cmd>ObsidianDailies<CR>", desc = "Daily Notes" },
      { prefix .. "w", "<cmd>ObsidianWorkspace<CR>", desc = "Workspace" },
      { prefix .. "n", create_para_note, desc = "New Note" },
      { prefix .. "r", "<cmd>ObsidianRename<CR>", desc = "Rename" },
      { prefix .. "a", move_to_archive, desc = "Archive Note" },
      { prefix .. "l", "<cmd>ObsidianLink<CR>", mode = "v", desc = "Link" },
      { prefix .. "L", "<cmd>ObsidianLinks<CR>", desc = "Links" },
      { prefix .. "N", "<cmd>ObsidianLinkNew<CR>", mode = "v", desc = "New Link" },
      { prefix .. "b", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks" },
      { prefix .. "t", "<cmd>ObsidianTags<CR>", desc = "Tags" },
      { prefix .. "e", "<cmd>ObsidianExtractNote<CR>", mode = "v", desc = "Extract Note" },
      {
        prefix .. "f",
        function()
          require("conform").format({ lsp_fallback = true })
        end,
        desc = "Format Note",
      },
    },

    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      ui = { enable = false },
      workspaces = {
        {
          name = "my-notes",
          path = "~/vaults/my-notes",
        },
      },
      completion = {
        nvim_cmp = false,
        blink = true,
      },
      picker = {
        name = "snacks.pick",
      },
      templates = {
        subdir = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      mappings = {
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<C-c>"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "obsidian", icon = " ", mode = { "n", "v" } },
      },
    },
  },
}
