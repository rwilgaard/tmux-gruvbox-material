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
  set status-bg "${dark2}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${light2},bg=${dark4},align=centre"
  set message-command-style "fg=${light2},bg=${dark4},align=centre"

  # panes
  set pane-border-style "fg=${dark4}"
  set pane-active-border-style "fg=${light2}"

  # windows
  setw window-status-activity-style "fg=${light2},bg=${dark3},none"
  setw window-status-separator ""
  setw window-status-style "fg=${light2},bg=${dark3},none"
  set window-style "bg=${dark1}"
  set window-active-style "bg=${dark1}"

  # --------=== Statusline
  local date_time
  date_time="$(get_tmux_option "@gruvbox_material_date_time" "on")"
  readonly date_time

  local show_window
  readonly show_window="#[fg=$dark1,bg=$light2]  #[fg=$light1,bg=$dark3] #W "

  local show_session
  readonly show_session="#[fg=$dark1,bg=$light2]  #[fg=$light1,bg=$dark3] #S "

  local show_date_time
  readonly show_date_time="#[fg=$dark1,bg=$light2]  #[fg=$light1,bg=$dark3] %H:%M "

  local show_directory_in_window_status
  readonly show_directory_in_window_status="#[fg=$light2,bg=$dark4,bold] #I #[fg=$light2,bg=$dark3,nobold] #{b:pane_current_path} "

  local show_directory_in_window_status_current
  readonly show_directory_in_window_status_current="#[fg=$dark1,bg=$light2,bold] #I #[fg=$light1,bg=$dark3] #{b:pane_current_path} "
  # readonly show_directory_in_window_status_current="#[fg=$dark1,bg=$light2,bold] #I #[fg=$light1,bg=$dark3] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "

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
  setw clock-mode-colour "${light1}"
  setw mode-style "fg=${dark1} bg=${light2} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
