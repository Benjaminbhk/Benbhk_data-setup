#!/usr/bin/env ruby -wU

CONSTANTS = {
    'PYTHON_VERSION' => "3.9.6",
    'REQUIREMENTS_URL' => "https://raw.githubusercontent.com/lewagon/data-runner/py-3.9.6-pandas-1.3/requirements.txt",
    'PIP_CHECKER_URL' => "https://gist.githubusercontent.com/krokrob/2e5a61b20582b55bbb034c4ea1e9f633/raw/95fba0d6430682a682dd92409b0878c9edf6e125/pip_check.sh"
    'PIP_LOADER_URL' => "https://gist.githubusercontent.com/krokrob/90e35dee7ed2b20852b099331510b369/raw/09178c49db6e7537eed68335a25fbb00c7ca1fd4/pip_check.py"
}

# NOTE(ssaunier): This script needs https://github.com/lewagon/setup to be cloned as well
MAC_OS = %w[
  intro
  setup/zoom
  setup/github
  setup/macos_apple_silicon
  setup/macos_command_line_tools
  homebrew
  chrome
  setup/macos_vscode
  vscode_extensions
  setup/vscode_liveshare
  setup/oh_my_zsh
  github_rsa
  setup/gh_cli
  dotfiles
  osx_python
  virtualenv
  pip
  nbextensions
  docker
  gcp_cli_setup
  gcp_setup
  gcp_setup_mid
  gcp_setup_end
  setup/kitt
  setup/macos_slack
  setup/slack_settings
  kata
].freeze

WINDOWS = %w[
  intro
  setup/zoom
  setup/github
  setup/windows_version
  setup/windows_virtualization
  setup/windows_wsl
  setup/windows_ubuntu
  chrome
  setup/windows_vscode
  vscode_extensions
  setup/vscode_liveshare
  setup/windows_terminal
  setup/git
  setup/zsh
  setup/oh_my_zsh
  github_rsa
  setup/windows_browser
  setup/gh_cli
  ubuntu_gcloud
  dotfiles
  setup/windows_ssh
  ubuntu_python
  virtualenv
  pip
  win_jupyter
  nbextensions
  setup/windows_settings
  win_vs_redistributable
  ubuntu_docker
  gcp_setup
  gcp_setup_wsl
  gcp_setup_end
  setup/kitt
  setup/windows_slack
  setup/slack_settings
  kata
].freeze

LINUX = %w[
  intro
  setup/zoom
  setup/github
  setup/ubuntu_vscode
  vscode_extensions
  setup/vscode_liveshare
  setup/git
  chrome
  setup/zsh
  setup/oh_my_zsh
  github_rsa
  setup/gh_cli
  ubuntu_gcloud
  dotfiles
  ubuntu_python
  virtualenv
  pip
  nbextensions
  ubuntu_docker
  gcp_setup
  gcp_setup_linux
  gcp_setup_end
  setup/kitt
  setup/ubuntu_slack
  setup/slack_settings
  kata
]

filenames = {
  "WINDOWS.md" => WINDOWS,
  "macOS.md" => MAC_OS,
  "LINUX.md" => LINUX
}

DEFAULT_SUBS = {
  "<CODE_EDITOR>" => "VS Code",
  "<CODE_EDITOR_CMD>" => "code"
}

subs = {
  "WINDOWS.md" => DEFAULT_SUBS,
  "macOS.md" => DEFAULT_SUBS,
  "LINUX.md" => DEFAULT_SUBS,
  "macOS_M1.md" => DEFAULT_SUBS,
}

delimiters = {
  "WINDOWS.md" => ["\\$WINDOWS_START\n", "\\$WINDOWS_END\n"],
  "macOS.md" => ["\\$MAC_START\n", "\\$MAC_END\n"],
  "LINUX.md" => ["\\$LINUX_START\n", "\\$LINUX_END\n"]
}

filenames.each do |filename, partials|
  File.open(filename.to_s, "w:utf-8") do |f|
    partials.each do |partial|
      match_data = partial.match(/setup\/(?<partial>[0-9a-z_]+)/)
      if match_data
        require 'open-uri'
        content = URI.open(File.join("https://raw.githubusercontent.com/lewagon/setup/master", "_partials", "#{match_data[:partial]}.md"))
                .string
        # replace data-setup repo relative path by setup repo URL
        image_paths = content.scan(/\!\[.*\]\((.*)\)/).flatten
        image_paths.each { |ip| content.gsub!(ip, "https://github.com/lewagon/setup/blob/master/#{ip}")}
      else
        file = File.join("_partials", "#{partial}.md")
        content = File.read(file, encoding: "utf-8")
      end
      # iterate through the patterns to replace in the file depending on the OS
      subs[filename].each do |pattern, replace|
        content.gsub!(pattern, replace)
      end
      # remove the OS dependant blocks
      removed_blocks = delimiters.keys - [filename]
      removed_blocks.each do |block|
        delimiter_start, delimiter_end = delimiters[block]
        pattern = "#{delimiter_start}(.|\n)*?(?<!#{delimiter_end})#{delimiter_end}"
        content.gsub!(/#{pattern}/, "")
      end
      # remove the OS dependant block delimiters
      delimiters[filename].each do |delimiter|
        content.gsub!(/#{delimiter}/, "")
      end
      CONSTANTS.each do |placeholder, value|
        content.gsub!("<#{placeholder}>", value)
      end
      f << content
      f << "\n\n"
    end
  end
end
