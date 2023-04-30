#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="$(get_tmux_option "@gruvbox_material_flavour" "dark")"

  # Aggregate all commands in one array
  local tmux_commands=()

  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/gruvbox-material-${theme}.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${bg1}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${grey2},bg=${bg4},align=centre"
  set message-command-style "fg=${grey2},bg=${bg4},align=centre"

  # panes
  set pane-border-style "fg=${bg4}"
  set pane-active-border-style "fg=${grey2}"

  # windows
  setw window-status-activity-style "fg=${grey2},bg=${bg2},none"
  setw window-status-separator ""
  setw window-status-style "fg=${grey2},bg=${bg2},none"
  set window-style "bg=${bg0}"
  set window-active-style "bg=${bg0}"

  # --------=== Statusline
  local date_time
  date_time="$(get_tmux_option "@gruvbox_material_date_time" "on")"
  readonly date_time

  local show_window
  readonly show_window="#[fg=$bg0,bg=$grey2]  #[fg=$fg1,bg=$bg3] #W "

  local show_session
  readonly show_session="#[fg=$bg0,bg=$grey2]  #[fg=$fg1,bg=$bg3] #S "

  local show_date_time
  readonly show_date_time="#[fg=$bg0,bg=$grey2]  #[fg=$fg1,bg=$bg3] %H:%M "

  local show_directory_in_window_status
  readonly show_directory_in_window_status="#[fg=$grey2,bg=$bg5] #I #[fg=$grey2,bg=$bg3] #{b:pane_current_path} "

  local show_directory_in_window_status_current
  readonly show_directory_in_window_status_current="#[fg=$bg0,bg=$grey2,bold] #I #[fg=$fg1,bg=$bg3] #{b:pane_current_path} "
  # readonly show_directory_in_window_status_current="#[fg=$bg0,bg=$grey2,bold] #I #[fg=$fg1,bg=$bg2] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "

  # Right column 1 by default shows the Window name.
  local right_column1=$show_window

  # Right column 2 by default shows the current Session name.
  local right_column2=$show_session

  # Window status by default shows the current directory basename.
  local window_status_format=$show_directory_in_window_status
  local window_status_current_format=$show_directory_in_window_status_current

  if [[ "${date_time}" != "off" ]]; then
    right_column2=$right_column2$show_date_time
  fi

  set status-left ""

  set status-right "${right_column1}${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  setw clock-mode-colour "${fg1}"
  setw mode-style "fg=${bg0} bg=${grey2} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
