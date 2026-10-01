-- =============================================================================
-- My NVIm config as proof of not needing to learn how to use VIm
-- =============================================================================

-- =============================================================================
-- Disable unused built-in plugins
-- =============================================================================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

-- =============================================================================
-- Core Options
-- =============================================================================
local o, opt, g = vim.o, vim.opt, vim.g

-- Leader
g.mapleader = ' '
g.maplocalleader = ' '

-- UI
o.number = true
o.relativenumber = false
o.cursorline = true
o.signcolumn = 'yes'
o.wrap = false
o.scrolloff = 8
o.sidescrolloff = 8
o.termguicolors = true
o.showmode = false
o.laststatus = 3

-- Editing (4-space tabs)
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true
o.breakindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- Splits
o.splitbelow = true
o.splitright = true

-- Performance
o.updatetime = 200
o.timeoutlen = 300
o.redrawtime = 1500

-- Files
o.swapfile = false
o.backup = false
o.undofile = true
o.undodir = vim.fn.stdpath('data') .. '/undo'

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }
o.pumheight = 10

-- Mouse & Clipboard
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

-- =============================================================================
-- Plugin Manager
-- =============================================================================
local data_path = vim.fn.stdpath('data') .. '/site'
local mini_path = data_path .. '/pack/deps/start/mini.nvim'

if not vim.uv.fs_stat(mini_path) then
  vim.notify('Installing mini.nvim...')
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  })
  vim.cmd('packadd mini.nvim | helptags ALL')
end

require('mini.deps').setup({ path = { package = data_path } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- =============================================================================
-- Plugins - Immediate
-- =============================================================================
now(function()
  add('nvim-mini/mini.nvim')

  add('nvim-tree/nvim-web-devicons')
  require('nvim-web-devicons').setup({ default = true })

  add('nvim-tree/nvim-tree.lua')
  require('nvim-tree').setup({
    view = { width = 30 },
    renderer = {
      icons = { show = { file = true, folder = true, folder_arrow = true } },
    },
    filters = { dotfiles = false },
    git = { enable = true, ignore = false },
  })

  require('mini.statusline').setup({
    use_icons = true,
    set_vim_settings = false,
  })
end)

-- =============================================================================
-- Plugins - Deferred
-- =============================================================================
later(function()
  require('mini.pick').setup({
    mappings = { move_down = '<C-j>', move_up = '<C-k>' },
  })

  add('lewis6991/gitsigns.nvim')
  require('gitsigns').setup({
    signs = {
      add = { text = '│' },
      change = { text = '│' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end
      map('n', ']h', gs.next_hunk, 'Next hunk')
      map('n', '[h', gs.prev_hunk, 'Prev hunk')
      map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>hb', gs.blame_line, 'Blame line')
    end,
  })

  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'query', 'bash', 'markdown' },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
  })

  require('mini.pairs').setup()
  require('mini.surround').setup()
  require('mini.comment').setup()
  require('mini.indentscope').setup({ symbol = '│', draw = { delay = 50 } })
end)

-- =============================================================================
-- Completion
-- =============================================================================
later(function()
  add('hrsh7th/nvim-cmp')
  add('hrsh7th/cmp-nvim-lsp')
  add('hrsh7th/cmp-buffer')
  add('hrsh7th/cmp-path')
  add('L3MON4D3/LuaSnip')
  add('saadparwaiz1/cmp_luasnip')

  local cmp = require('cmp')
  local luasnip = require('luasnip')

  cmp.setup({
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer', keyword_length = 3 },
      { name = 'path' },
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    performance = {
      debounce = 60,
      throttle = 30,
      fetching_timeout = 200,
    },
  })
end)

-- =============================================================================
-- LSP
-- =============================================================================
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('n', 'gr', vim.lsp.buf.references, 'References')
    map('n', 'K', vim.lsp.buf.hover, 'Hover')
    map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
    map('i', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('n', '<leader>D', vim.lsp.buf.type_definition, 'Type definition')
    map('n', '<leader>ds', vim.diagnostic.open_float, 'Show diagnostics')
    map('n', '[d', vim.diagnostic.goto_prev, 'Prev diagnostic')
    map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

    -- Manual format: <leader>fm (not on save — clangd ignores formatting_options
    -- and rewrites indentation to its own style, typically 2-space LLVM)
    if client and client.server_capabilities.documentFormattingProvider then
      map('n', '<leader>fm', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
      end, 'Format buffer')
    end

    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = '*' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'always' },
})

later(function()
  local cmp_lsp = require('cmp_nvim_lsp')
  local capabilities = cmp_lsp.default_capabilities()

  if vim.fn.executable('clangd') == 1 then
    local gcc_paths = {}
    local handle = io.popen("echo | gcc -E -Wp,-v - 2>&1 | grep '^ /' | tr -d ' '")
    if handle then
      for line in handle:lines() do
        table.insert(gcc_paths, '-isystem')
        table.insert(gcc_paths, line)
      end
      handle:close()
    end

    local fallback = { '-std=c11', '-Wall', '-Wextra' }
    vim.list_extend(fallback, gcc_paths)

    vim.lsp.config.clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--completion-style=detailed',
        '--header-insertion=iwyu',
        '--query-driver=/usr/bin/gcc,/usr/bin/g++',
        '--fallback-style={IndentWidth: 4, TabWidth: 4, UseTab: Never, ColumnLimit: 0}',
        '-j=4',
      },
      filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
      root_markers = { 'compile_commands.json', '.clangd', '.git', 'Makefile' },
      capabilities = capabilities,
      init_options = { fallbackFlags = fallback },
    }
    vim.lsp.enable('clangd')
  else
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'c', 'cpp' },
      once = true,
      callback = function()
        vim.notify('Install clangd: sudo apt install clangd', vim.log.levels.WARN)
      end,
    })
  end

  -- Python (pyright)
  if vim.fn.executable('pyright-langserver') == 1 then
    vim.lsp.config.pyright = {
      cmd = { 'pyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'workspace',
          },
        },
      },
    }
    vim.lsp.enable('pyright')
  else
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'python',
      once = true,
      callback = function()
        vim.notify('Install pyright: npm i -g pyright', vim.log.levels.WARN)
      end,
    })
  end
end)

-- =============================================================================
-- Build & Terminal System
-- =============================================================================
local Term = {
  buf = nil,
  win = nil,
  job_id = nil,
  last_binary = nil,
  project = nil, -- Cached project info
}

function Term.open()
  if Term.win and vim.api.nvim_win_is_valid(Term.win) then
    vim.api.nvim_set_current_win(Term.win)
    return
  end

  vim.cmd('botright ' .. math.floor(vim.o.lines * 0.25) .. 'split')
  Term.win = vim.api.nvim_get_current_win()

  if Term.buf and vim.api.nvim_buf_is_valid(Term.buf) then
    vim.api.nvim_win_set_buf(Term.win, Term.buf)
  else
    vim.cmd('terminal')
    Term.buf = vim.api.nvim_get_current_buf()
    Term.job_id = vim.b.terminal_job_id
  end

  vim.wo[Term.win].number = false
  vim.wo[Term.win].relativenumber = false
  vim.wo[Term.win].signcolumn = 'no'
  vim.wo[Term.win].winfixheight = true

  vim.cmd('startinsert')
end

function Term.close()
  if Term.win and vim.api.nvim_win_is_valid(Term.win) then
    vim.api.nvim_win_close(Term.win, true)
    Term.win = nil
  end
end

function Term.toggle()
  if Term.win and vim.api.nvim_win_is_valid(Term.win) then
    Term.close()
  else
    Term.open()
  end
end

function Term.send(cmd)
  if not Term.job_id or not vim.api.nvim_buf_is_valid(Term.buf) then
    Term.open()
    vim.defer_fn(function()
      Term.job_id = vim.b[Term.buf].terminal_job_id
      if Term.job_id then
        vim.fn.chansend(Term.job_id, cmd .. '\n')
      end
    end, 100)
  else
    Term.open()
    vim.fn.chansend(Term.job_id, cmd .. '\n')
  end
end

-- Find CMakeLists.txt by walking up from the current file
local function find_cmake_root(start_path)
  local path = start_path
  while path and path ~= '/' do
    local cmake_file = path .. '/CMakeLists.txt'
    if vim.fn.filereadable(cmake_file) == 1 then
      return path, cmake_file
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
  return nil, nil
end

-- Parse CMakeLists.txt to detect project type and executable name
local function parse_cmake(cmake_file)
  local content = vim.fn.readfile(cmake_file)
  local text = table.concat(content, '\n')

  local info = {
    has_qt = false,
    has_raylib = false,
    executable = nil,
    project_name = nil,
    qt_version = nil,
  }

  -- Detect project name
  local proj = text:match('project%s*%(%s*([%w_-]+)')
  if proj then
    info.project_name = proj
  end

  -- Detect Qt (Qt5 or Qt6)
  if text:match('find_package%s*%(%s*Qt6') or text:match('Qt6::') then
    info.has_qt = true
    info.qt_version = 6
  elseif text:match('find_package%s*%(%s*Qt5') or text:match('Qt5::') then
    info.has_qt = true
    info.qt_version = 5
  elseif text:match('find_package%s*%(%s*Qt%s') or text:match('QT_') then
    info.has_qt = true
    info.qt_version = 5
  end

  -- Detect raylib
  if text:match('find_package%s*%(%s*raylib') or text:match('raylib') or text:match('RAYLIB') then
    info.has_raylib = true
  end

  -- Find executable name (try multiple patterns)
  local exe = text:match('add_executable%s*%(%s*([%w_-]+)')
    or text:match('qt_add_executable%s*%(%s*([%w_-]+)')
    or text:match('qt6_add_executable%s*%(%s*([%w_-]+)')
    or text:match('qt5_add_executable%s*%(%s*([%w_-]+)')

  if exe then
    info.executable = exe
  elseif info.project_name then
    info.executable = info.project_name
  end

  return info
end

-- Detect project type for current file
function Term.detect_project()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then return nil end

  local dir = vim.fn.fnamemodify(file, ':h')
  local root, cmake_file = find_cmake_root(dir)

  if not root then
    return nil
  end

  local info = parse_cmake(cmake_file)
  info.root = root
  info.cmake_file = cmake_file
  info.build_dir = root .. '/build'

  return info
end

-- Build using CMake
function Term.cmake_build(clean)
  local project = Term.detect_project()

  if not project then
    -- Fallback to single-file compilation
    Term.compile_single()
    return
  end

  Term.project = project

  local build_dir = project.build_dir
  local root = project.root

  -- Save current file
  local src_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(src_buf, function() vim.cmd('silent write') end)

  local cmake_opts = ' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'

  -- Qt-specific configuration
  if project.has_qt then
    cmake_opts = cmake_opts .. ' -DCMAKE_AUTOMOC=ON -DCMAKE_AUTORCC=ON -DCMAKE_AUTOUIC=ON'
    if project.qt_version == 6 then
      cmake_opts = cmake_opts .. ' -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6'
    end
  end

  -- raylib specific (usually just needs standard cmake)
  if project.has_raylib then
    cmake_opts = cmake_opts .. ' -DCMAKE_BUILD_TYPE=Debug'
  end

  local cmd
  if clean or vim.fn.isdirectory(build_dir) == 0 then
    -- Full rebuild: create build dir, configure, build, and symlink compile_commands.json
    cmd = string.format(
      "mkdir -p '%s' && cd '%s' && cmake%s '%s' && ln -sf '%s/compile_commands.json' '%s/compile_commands.json' ; cd '%s' && cmake --build . -j$(nproc)",
      build_dir, build_dir, cmake_opts, root, build_dir, root, build_dir
    )
  else
    -- Incremental build
    cmd = string.format("cd '%s' && cmake --build . -j$(nproc)", build_dir)
  end

  -- Store executable path for run command
  if project.executable then
    Term.last_binary = build_dir .. '/' .. project.executable
  end

  local type_str = ''
  if project.has_qt then type_str = 'Qt' .. (project.qt_version or '') .. ' ' end
  if project.has_raylib then type_str = type_str .. 'raylib ' end
  if type_str == '' then type_str = 'CMake ' end

  vim.notify('Building ' .. type_str .. 'project: ' .. (project.project_name or 'unknown'), vim.log.levels.INFO)
  Term.send(cmd)
end

-- Single-file compilation (original behavior)
function Term.compile_single()
  local src_buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(src_buf)
  local ft = vim.bo[src_buf].filetype

  if file == '' or file:match('%[.*%]') then
    vim.notify('Open a C/C++ file first', vim.log.levels.ERROR)
    return
  end
  if ft ~= 'c' and ft ~= 'cpp' then
    vim.notify('Not a C/C++ file', vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_call(src_buf, function() vim.cmd('silent write') end)

  local out = file:gsub('%.[^.]+$', '')
  Term.last_binary = out
  Term.project = nil

  local cc = ft == 'cpp' and 'g++' or 'gcc'
  local std = ft == 'cpp' and '-std=c++20' or '-std=c11'
  local cmd = string.format("%s %s -Wall -Wextra -O2 -g '%s' -o '%s'", cc, std, file, out)

  Term.send(cmd)
end

-- Run Python file
function Term.run_python()
  local src_buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(src_buf)

  if file == '' then
    vim.notify('Open a Python file first', vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_call(src_buf, function() vim.cmd('silent write') end)

  local python = vim.fn.executable('python3') == 1 and 'python3' or 'python'
  Term.send(string.format("%s '%s'", python, file))
end

-- Main compile function - auto-detects CMake vs single file vs Python
function Term.compile()
  local src_buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(src_buf)
  local ft = vim.bo[src_buf].filetype

  if file == '' or file:match('%[.*%]') then
    vim.notify('Open a source file first', vim.log.levels.ERROR)
    return
  end

  if ft == 'python' then
    Term.run_python()
    return
  end

  if ft ~= 'c' and ft ~= 'cpp' and ft ~= 'cmake' then
    vim.notify('Not a supported file type (C/C++/Python/CMake)', vim.log.levels.ERROR)
    return
  end

  -- Check if this is a CMake project
  local project = Term.detect_project()
  if project then
    Term.cmake_build(false)
  else
    Term.compile_single()
  end
end

-- Clean rebuild
function Term.clean_build()
  local project = Term.detect_project()
  if project then
    -- Remove build directory and rebuild
    local cmd = string.format("rm -rf '%s'", project.build_dir)
    vim.notify('Cleaning build directory...', vim.log.levels.INFO)
    vim.fn.system(cmd)
    Term.cmake_build(true)
  else
    Term.compile_single()
  end
end

-- Run the compiled binary
function Term.run_with_args()
  if not Term.last_binary then
    vim.notify('Compile first with <F5>', vim.log.levels.ERROR)
    return
  end

  -- Check if binary exists
  if vim.fn.filereadable(Term.last_binary) ~= 1 then
    -- Try to find it in build directory
    if Term.project and Term.project.executable then
      local possible_paths = {
        Term.project.build_dir .. '/' .. Term.project.executable,
        Term.project.build_dir .. '/bin/' .. Term.project.executable,
        Term.project.build_dir .. '/src/' .. Term.project.executable,
      }
      for _, path in ipairs(possible_paths) do
        if vim.fn.filereadable(path) == 1 then
          Term.last_binary = path
          break
        end
      end
    end
  end

  if vim.fn.filereadable(Term.last_binary) ~= 1 then
    vim.notify('Binary not found. Build the project first.', vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = 'Args: ' }, function(args)
    if args == nil then return end
    local cmd = "'" .. Term.last_binary .. "'"
    if args ~= '' then
      cmd = cmd .. ' ' .. args
    end

    -- For Qt apps, might need to set some env vars
    if Term.project and Term.project.has_qt then
      cmd = 'QT_QPA_PLATFORM=xcb ' .. cmd
    end

    Term.send(cmd)
  end)
end

-- Run without prompting for args (quick run)
function Term.run()
  if not Term.last_binary then
    vim.notify('Compile first with <F5>', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(Term.last_binary) ~= 1 then
    if Term.project and Term.project.executable then
      local possible_paths = {
        Term.project.build_dir .. '/' .. Term.project.executable,
        Term.project.build_dir .. '/bin/' .. Term.project.executable,
        Term.project.build_dir .. '/src/' .. Term.project.executable,
      }
      for _, path in ipairs(possible_paths) do
        if vim.fn.filereadable(path) == 1 then
          Term.last_binary = path
          break
        end
      end
    end
  end

  if vim.fn.filereadable(Term.last_binary) ~= 1 then
    vim.notify('Binary not found. Build the project first.', vim.log.levels.ERROR)
    return
  end

  local cmd = "'" .. Term.last_binary .. "'"
  if Term.project and Term.project.has_qt then
    cmd = 'QT_QPA_PLATFORM=xcb ' .. cmd
  end

  Term.send(cmd)
end

-- Show project info
function Term.show_project_info()
  local project = Term.detect_project()
  if not project then
    vim.notify('No CMake project detected. Single-file mode.', vim.log.levels.INFO)
    return
  end

  local lines = {
    'CMake Project Info:',
    '  Root: ' .. project.root,
    '  Project: ' .. (project.project_name or 'unknown'),
    '  Executable: ' .. (project.executable or 'unknown'),
    '  Build dir: ' .. project.build_dir,
  }

  if project.has_qt then
    table.insert(lines, '  Framework: Qt' .. (project.qt_version or ''))
  end
  if project.has_raylib then
    table.insert(lines, '  Framework: raylib')
  end

  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

-- =============================================================================
-- Claude Code Integration
-- =============================================================================
local Claude = {
  buf = nil,
  win = nil,
  job_id = nil,
}

function Claude.open()
  if Claude.win and vim.api.nvim_win_is_valid(Claude.win) then
    vim.api.nvim_set_current_win(Claude.win)
    vim.cmd('startinsert')
    return
  end

  -- Open a vertical split on the right (40% width)
  local width = math.floor(vim.o.columns * 0.4)
  vim.cmd('botright ' .. width .. 'vsplit')
  Claude.win = vim.api.nvim_get_current_win()

  if Claude.buf and vim.api.nvim_buf_is_valid(Claude.buf) then
    vim.api.nvim_win_set_buf(Claude.win, Claude.buf)
  else
    vim.cmd('terminal claude')
    Claude.buf = vim.api.nvim_get_current_buf()
    Claude.job_id = vim.b.terminal_job_id
  end

  vim.wo[Claude.win].number = false
  vim.wo[Claude.win].relativenumber = false
  vim.wo[Claude.win].signcolumn = 'no'
  vim.wo[Claude.win].winfixwidth = true

  vim.cmd('startinsert')
end

function Claude.close()
  if Claude.win and vim.api.nvim_win_is_valid(Claude.win) then
    vim.api.nvim_win_close(Claude.win, true)
    Claude.win = nil
  end
end

function Claude.toggle()
  if Claude.win and vim.api.nvim_win_is_valid(Claude.win) then
    Claude.close()
  else
    Claude.open()
  end
end

function Claude.send(text)
  if not Claude.job_id or not Claude.buf or not vim.api.nvim_buf_is_valid(Claude.buf) then
    Claude.open()
    vim.defer_fn(function()
      Claude.job_id = vim.b[Claude.buf].terminal_job_id
      if Claude.job_id then
        vim.fn.chansend(Claude.job_id, text)
      end
    end, 200)
  else
    Claude.open()
    vim.fn.chansend(Claude.job_id, text)
  end
end

-- Send visual selection to Claude
function Claude.send_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.visualmode() })
  if #lines == 0 then return end

  local text = table.concat(lines, '\n') .. '\n'
  Claude.send(text)
end

-- Send current file to Claude with a prompt
function Claude.send_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('No file open', vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = 'Ask Claude about this file: ' }, function(prompt)
    if not prompt or prompt == '' then return end
    local cmd = prompt .. ' ' .. file .. '\n'
    Claude.send(cmd)
  end)
end

-- =============================================================================
-- Keymaps
-- =============================================================================
local map = vim.keymap.set

-- Build & Terminal
map('n', '<F5>', Term.compile, { desc = 'Build (CMake or single file)' })
map('n', '<S-F5>', Term.clean_build, { desc = 'Clean rebuild' })
map('n', '<F6>', Term.run_with_args, { desc = 'Run with args' })
map('n', '<S-F6>', Term.run, { desc = 'Run (no args)' })
map('n', '<F7>', Term.toggle, { desc = 'Toggle terminal' })
map('n', '<leader>pi', Term.show_project_info, { desc = 'Project info' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-q>', function() Term.close() end, { desc = 'Close terminal' })

-- Claude Code
map('n', '<leader>cc', Claude.toggle, { desc = 'Toggle Claude' })
map('n', '<leader>cf', Claude.send_file, { desc = 'Send file to Claude' })
map('v', '<leader>cs', Claude.send_selection, { desc = 'Send selection to Claude' })

-- File tree
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Explorer' })
map('n', '<leader>E', '<cmd>NvimTreeFindFile<cr>', { desc = 'Explorer (find)' })

-- Fuzzy finder
map('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Files' })
map('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Grep' })
map('n', '<leader>fb', '<cmd>Pick buffers<cr>', { desc = 'Buffers' })
map('n', '<leader>fh', '<cmd>Pick help<cr>', { desc = 'Help' })
map('n', '<leader>fr', '<cmd>Pick oldfiles<cr>', { desc = 'Recent' })

-- Buffers
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })

-- Windows
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Height++' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Height--' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Width--' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Width++' })

-- Quality of life
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search' })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })
map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move down' })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move up' })
map('n', 'J', 'mzJ`z', { desc = 'Join lines' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
map('n', 'n', 'nzzzv', { desc = 'Next match' })
map('n', 'N', 'Nzzzv', { desc = 'Prev match' })

-- Quickfix
map('n', '<leader>qo', '<cmd>copen<cr>', { desc = 'Open quickfix' })
map('n', '<leader>qc', '<cmd>cclose<cr>', { desc = 'Close quickfix' })
map('n', '[q', '<cmd>cprev<cr>', { desc = 'Prev quickfix' })
map('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

-- =============================================================================
-- Autocommands
-- =============================================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Enforce 4-space indentation (treesitter indent can override shiftwidth)
autocmd('FileType', {
  group = augroup('EnforceIndent', {}),
  pattern = { 'c', 'cpp', 'python', 'lua', 'cmake' },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})

autocmd('TextYankPost', {
  group = augroup('YankHighlight', {}),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

autocmd('BufReadPost', {
  group = augroup('RestoreCursor', {}),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lines = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd('VimResized', {
  group = augroup('ResizeSplits', {}),
  callback = function() vim.cmd('tabdo wincmd =') end,
})

autocmd('FileType', {
  group = augroup('CloseWithQ', {}),
  pattern = { 'help', 'qf', 'man', 'notify', 'checkhealth' },
  callback = function(e)
    vim.bo[e.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = e.buf, silent = true })
  end,
})

autocmd('VimEnter', {
  group = augroup('NvimTreeOpen', {}),
  callback = function(data)
    if data.file == '' or vim.fn.isdirectory(data.file) == 1 then
      if vim.fn.isdirectory(data.file) == 1 then
        vim.cmd.cd(data.file)
      end
      require('nvim-tree.api').tree.open()
    end
  end,
})

-- =============================================================================
-- VS Code Dark+ Theme
-- =============================================================================
later(function()
  local c = {
    bg = '#1e1e1e',
    bg_light = '#252526',
    bg_highlight = '#2d2d2d',
    bg_selection = '#264f78',
    fg = '#d4d4d4',
    fg_dark = '#808080',
    comment = '#6a9955',
    string = '#ce9178',
    keyword = '#569cd6',
    keyword_ctrl = '#c586c0',
    func = '#dcdcaa',
    type = '#4ec9b0',
    variable = '#9cdcfe',
    number = '#b5cea8',
    operator = '#d4d4d4',
    error = '#f44747',
    warning = '#ff8800',
    info = '#6796e6',
    hint = '#b267e6',
  }

  vim.cmd('highlight clear')
  vim.o.background = 'dark'

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Editor
  hi('Normal', { fg = c.fg, bg = c.bg })
  hi('NormalFloat', { fg = c.fg, bg = c.bg_light })
  hi('FloatBorder', { fg = c.fg_dark, bg = c.bg_light })
  hi('Cursor', { fg = c.bg, bg = c.fg })
  hi('CursorLine', { bg = c.bg_highlight })
  hi('CursorLineNr', { fg = c.fg, bold = true })
  hi('LineNr', { fg = c.fg_dark })
  hi('SignColumn', { bg = c.bg })
  hi('VertSplit', { fg = c.bg_highlight })
  hi('WinSeparator', { fg = c.bg_highlight })
  hi('StatusLine', { fg = c.fg, bg = c.bg_light })
  hi('StatusLineNC', { fg = c.fg_dark, bg = c.bg_light })
  hi('Pmenu', { fg = c.fg, bg = c.bg_light })
  hi('PmenuSel', { fg = c.fg, bg = c.bg_selection })
  hi('PmenuSbar', { bg = c.bg_light })
  hi('PmenuThumb', { bg = c.fg_dark })
  hi('TabLine', { fg = c.fg_dark, bg = c.bg_light })
  hi('TabLineFill', { bg = c.bg_light })
  hi('TabLineSel', { fg = c.fg, bg = c.bg })
  hi('Visual', { bg = c.bg_selection })
  hi('VisualNOS', { bg = c.bg_selection })
  hi('Search', { fg = c.bg, bg = c.func })
  hi('IncSearch', { fg = c.bg, bg = c.func })
  hi('MatchParen', { fg = c.func, bold = true, underline = true })
  hi('Folded', { fg = c.comment, bg = c.bg_light })
  hi('FoldColumn', { fg = c.fg_dark, bg = c.bg })
  hi('NonText', { fg = c.bg_highlight })
  hi('SpecialKey', { fg = c.bg_highlight })
  hi('Whitespace', { fg = c.bg_highlight })
  hi('EndOfBuffer', { fg = c.bg })

  -- Syntax
  hi('Comment', { fg = c.comment, italic = true })
  hi('Constant', { fg = c.variable })
  hi('String', { fg = c.string })
  hi('Character', { fg = c.string })
  hi('Number', { fg = c.number })
  hi('Boolean', { fg = c.keyword })
  hi('Float', { fg = c.number })
  hi('Identifier', { fg = c.variable })
  hi('Function', { fg = c.func })
  hi('Statement', { fg = c.keyword })
  hi('Conditional', { fg = c.keyword_ctrl })
  hi('Repeat', { fg = c.keyword_ctrl })
  hi('Label', { fg = c.keyword_ctrl })
  hi('Operator', { fg = c.operator })
  hi('Keyword', { fg = c.keyword })
  hi('Exception', { fg = c.keyword_ctrl })
  hi('PreProc', { fg = c.keyword_ctrl })
  hi('Include', { fg = c.keyword_ctrl })
  hi('Define', { fg = c.keyword_ctrl })
  hi('Macro', { fg = c.keyword_ctrl })
  hi('PreCondit', { fg = c.keyword_ctrl })
  hi('Type', { fg = c.type })
  hi('StorageClass', { fg = c.keyword })
  hi('Structure', { fg = c.type })
  hi('Typedef', { fg = c.type })
  hi('Special', { fg = c.variable })
  hi('SpecialChar', { fg = c.string })
  hi('Tag', { fg = c.keyword })
  hi('Delimiter', { fg = c.fg })
  hi('SpecialComment', { fg = c.comment })
  hi('Debug', { fg = c.error })
  hi('Underlined', { underline = true })
  hi('Error', { fg = c.error })
  hi('Todo', { fg = c.bg, bg = c.func, bold = true })

  -- Treesitter
  hi('@comment', { link = 'Comment' })
  hi('@string', { fg = c.string })
  hi('@string.escape', { fg = c.func })
  hi('@character', { fg = c.string })
  hi('@number', { fg = c.number })
  hi('@boolean', { fg = c.keyword })
  hi('@float', { fg = c.number })
  hi('@function', { fg = c.func })
  hi('@function.call', { fg = c.func })
  hi('@function.builtin', { fg = c.func })
  hi('@function.macro', { fg = c.func })
  hi('@method', { fg = c.func })
  hi('@method.call', { fg = c.func })
  hi('@constructor', { fg = c.type })
  hi('@parameter', { fg = c.variable })
  hi('@keyword', { fg = c.keyword })
  hi('@keyword.function', { fg = c.keyword })
  hi('@keyword.return', { fg = c.keyword_ctrl })
  hi('@keyword.operator', { fg = c.keyword })
  hi('@conditional', { fg = c.keyword_ctrl })
  hi('@repeat', { fg = c.keyword_ctrl })
  hi('@label', { fg = c.keyword_ctrl })
  hi('@include', { fg = c.keyword_ctrl })
  hi('@exception', { fg = c.keyword_ctrl })
  hi('@type', { fg = c.type })
  hi('@type.builtin', { fg = c.type })
  hi('@type.definition', { fg = c.type })
  hi('@type.qualifier', { fg = c.keyword })
  hi('@storageclass', { fg = c.keyword })
  hi('@namespace', { fg = c.type })
  hi('@variable', { fg = c.variable })
  hi('@variable.builtin', { fg = c.keyword })
  hi('@constant', { fg = c.variable })
  hi('@constant.builtin', { fg = c.keyword })
  hi('@constant.macro', { fg = c.keyword_ctrl })
  hi('@property', { fg = c.variable })
  hi('@field', { fg = c.variable })
  hi('@punctuation', { fg = c.fg })
  hi('@punctuation.delimiter', { fg = c.fg })
  hi('@punctuation.bracket', { fg = c.fg })
  hi('@punctuation.special', { fg = c.keyword_ctrl })
  hi('@operator', { fg = c.operator })
  hi('@preproc', { fg = c.keyword_ctrl })
  hi('@define', { fg = c.keyword_ctrl })

  -- LSP
  hi('DiagnosticError', { fg = c.error })
  hi('DiagnosticWarn', { fg = c.warning })
  hi('DiagnosticInfo', { fg = c.info })
  hi('DiagnosticHint', { fg = c.hint })
  hi('DiagnosticUnderlineError', { undercurl = true, sp = c.error })
  hi('DiagnosticUnderlineWarn', { undercurl = true, sp = c.warning })
  hi('DiagnosticUnderlineInfo', { undercurl = true, sp = c.info })
  hi('DiagnosticUnderlineHint', { undercurl = true, sp = c.hint })
  hi('DiagnosticVirtualTextError', { fg = c.error, bg = '#3d2023' })
  hi('DiagnosticVirtualTextWarn', { fg = c.warning, bg = '#3d3520' })
  hi('DiagnosticVirtualTextInfo', { fg = c.info, bg = '#203040' })
  hi('DiagnosticVirtualTextHint', { fg = c.hint, bg = '#302838' })
  hi('LspReferenceText', { bg = c.bg_highlight })
  hi('LspReferenceRead', { bg = c.bg_highlight })
  hi('LspReferenceWrite', { bg = c.bg_highlight })
  hi('LspInlayHint', { fg = c.fg_dark, italic = true })

  -- Git
  hi('GitSignsAdd', { fg = c.number })
  hi('GitSignsChange', { fg = c.info })
  hi('GitSignsDelete', { fg = c.error })
  hi('DiffAdd', { bg = '#2d4030' })
  hi('DiffChange', { bg = '#2d3040' })
  hi('DiffDelete', { bg = '#402d30' })
  hi('DiffText', { bg = '#3d4050' })

  -- Nvim-tree
  hi('NvimTreeNormal', { fg = c.fg, bg = c.bg_light })
  hi('NvimTreeFolderIcon', { fg = c.func })
  hi('NvimTreeFolderName', { fg = c.fg })
  hi('NvimTreeOpenedFolderName', { fg = c.fg, bold = true })
  hi('NvimTreeRootFolder', { fg = c.keyword_ctrl })
  hi('NvimTreeGitDirty', { fg = c.warning })
  hi('NvimTreeGitNew', { fg = c.number })

  -- Completion
  hi('CmpItemAbbr', { fg = c.fg })
  hi('CmpItemAbbrMatch', { fg = c.func, bold = true })
  hi('CmpItemAbbrMatchFuzzy', { fg = c.func })
  hi('CmpItemKind', { fg = c.keyword })
  hi('CmpItemMenu', { fg = c.fg_dark })
  hi('CmpItemKindFunction', { fg = c.func })
  hi('CmpItemKindMethod', { fg = c.func })
  hi('CmpItemKindVariable', { fg = c.variable })
  hi('CmpItemKindKeyword', { fg = c.keyword })
  hi('CmpItemKindText', { fg = c.fg })
  hi('CmpItemKindSnippet', { fg = c.keyword_ctrl })

  -- Mini plugins
  hi('MiniIndentscopeSymbol', { fg = c.bg_selection })
  hi('MiniStatuslineFilename', { fg = c.fg, bg = c.bg_light })
  hi('MiniStatuslineFileinfo', { fg = c.fg, bg = c.bg_light })
  hi('MiniPickNormal', { fg = c.fg, bg = c.bg_light })
  hi('MiniPickBorder', { fg = c.fg_dark, bg = c.bg_light })
  hi('MiniPickPrompt', { fg = c.func, bg = c.bg_light })
end)


